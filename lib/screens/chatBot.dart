import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _userInput = TextEditingController();
  static const apiKey = "AIzaSyCgFagW7p8FXQueEXxg2lySg_RGA3I6F_8";
  // Updated model names - prioritize working models
  static const List<Map<String, dynamic>> modelConfigs = [
    {'name': 'gemini-2.5-flash-lite', 'useBeta': false}, // Known to work
    {'name': 'gemini-1.5-flash', 'useBeta': true},       // v1beta only
    {'name': 'gemini-1.5-pro', 'useBeta': true},         // v1beta only
    {'name': 'gemini-2.5-flash', 'useBeta': false},      // May hit quota
    {'name': 'gemini-2.5-pro', 'useBeta': false},
  ];
  final List<Message> _messages = [];
  bool _isRequestInProgress = false;
  String? _workingModel; // Cache the working model
  
  String _getApiUrl(String modelName, {bool useBeta = false}) {
    // Try v1beta for models that might not be in v1
    final version = useBeta ? 'v1beta' : 'v1';
    return "https://generativelanguage.googleapis.com/$version/models/$modelName:generateContent";
  }
  
  // Function to list available models and their supported methods
  Future<List<Map<String, dynamic>>> _listAvailableModels() async {
    final results = <Map<String, dynamic>>[];
    
    // Try both v1 and v1beta
    for (final version in ['v1', 'v1beta']) {
      try {
        final response = await http.get(
          Uri.parse('https://generativelanguage.googleapis.com/$version/models?key=$apiKey'),
          headers: {'Content-Type': 'application/json'},
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final models = data['models'] as List?;
          if (models != null) {
            for (final model in models) {
              final name = model['name'] as String?;
              if (name != null && name.contains('gemini')) {
                final supportedMethods = model['supportedGenerationMethods'] as List? ?? [];
                final modelName = name.replaceAll('models/', '');
                results.add({
                  'name': modelName,
                  'version': version,
                  'supportsGenerateContent': supportedMethods.contains('generateContent'),
                });
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error listing models from $version: $e');
      }
    }
    
    debugPrint('Available models: $results');
    return results;
  }

  Future<void> sendMessage() async {
    final message = _userInput.text;
    if (message.isEmpty) return;

    setState(() {
      _messages.add(Message(isUser: true, message: message, date: DateTime.now()));
      _userInput.clear();
      _isRequestInProgress = true;
    });

    final prompt = "GPT, upon receiving the name of a human health disease, provide information including precautions, medicines, cures, and exercises. "
        "The response should be in headings format, consisting of 2 to 10 line per heading without any additional text. "
        "The disease is $message. If the input is not a recognized disease, respond with 'Unrecognized disease.'";

    // Adding a temporary "GPT is writing" message
    setState(() {
      _messages.add(Message(isUser: false, message: "MediGuide  is writing...", date: DateTime.now(), isTemporary: true));
    });

    // Use cached working model if available
    Map<String, dynamic>? workingConfig;
    if (_workingModel != null) {
      workingConfig = modelConfigs.firstWhere(
        (config) => config['name'] == _workingModel,
        orElse: () => modelConfigs[0],
      );
    }
    
    final configsToTry = workingConfig != null ? [workingConfig] : modelConfigs;
    http.Response? lastResponse;
    String? lastError;
    
    for (final config in configsToTry) {
      final modelName = config['name'] as String;
      final useBeta = config['useBeta'] as bool? ?? false;
      
      try {
        final url = _getApiUrl(modelName, useBeta: useBeta);
        debugPrint('Trying model: $modelName (${useBeta ? "v1beta" : "v1"})');
        
        final response = await http.post(
          Uri.parse('$url?key=$apiKey'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ],
            'generationConfig': {
              'temperature': 0.7,
              'topK': 40,
              'topP': 0.95,
              'maxOutputTokens': 2048,
            }
          }),
        );

        lastResponse = response;
        debugPrint('Response status for $modelName: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          // Cache the working model for future requests
          _workingModel = modelName;
          
          try {
            final responseData = jsonDecode(response.body);
            debugPrint('Response data keys: ${responseData.keys}');
            
            String responseText = "Sorry, I couldn't generate a response.";
            
            // Try different response structures
            if (responseData['candidates'] != null) {
              final candidates = responseData['candidates'] as List?;
              if (candidates != null && candidates.isNotEmpty) {
                final candidate = candidates[0];
                if (candidate['content'] != null) {
                  final content = candidate['content'];
                  if (content['parts'] != null) {
                    final parts = content['parts'] as List;
                    if (parts.isNotEmpty && parts[0]['text'] != null) {
                      responseText = parts[0]['text'] as String;
                    }
                  }
                }
              }
            } else if (responseData['text'] != null) {
              // Alternative response format
              responseText = responseData['text'] as String;
            } else {
              debugPrint('Unexpected response format: ${response.body}');
            }

            setState(() {
              // Remove the temporary message
              _messages.removeWhere((msg) => msg.isTemporary);

              _messages.add(Message(isUser: false, message: responseText, date: DateTime.now()));
              _isRequestInProgress = false;
            });
            return; // Success, exit the function
          } catch (e) {
            debugPrint('Error parsing response: $e');
            debugPrint('Response body: ${response.body}');
            lastError = "Failed to parse response: $e";
            continue; // Try next model
          }
        } else {
          // Parse error response
          debugPrint('Response body: ${response.body}');
          try {
            final errorData = jsonDecode(response.body);
            if (errorData['error'] != null) {
              final error = errorData['error'];
              final message = error['message'] ?? error.toString();
              final code = error['code'];
              lastError = message;
              debugPrint('API Error for $modelName: $message');
              
              // Handle quota errors (429) - wait and retry or skip
              if (response.statusCode == 429) {
                debugPrint('Quota exceeded for $modelName, trying next model...');
                continue; // Try next model
              }
              
              // If 404, try next model
              if (response.statusCode == 404) {
                continue;
              } else if (response.statusCode == 400 || response.statusCode == 403 || response.statusCode == 401) {
                // Bad request, auth error, or permission error - show error and stop
                break;
              }
            }
          } catch (e) {
            debugPrint('Could not parse error response: $e');
            lastError = response.body;
            if (response.statusCode == 404 || response.statusCode == 429) {
              continue; // Try next model
            } else {
              break; // Stop on other errors
            }
          }
        }
      } catch (e) {
        debugPrint('Exception caught for $modelName: $e');
        lastError = e.toString();
        continue; // Try next model
      }
    }
    
    // If we get here, all models failed
    String errorMessage = "Error: Failed to get response. Please try again.";
    if (lastResponse != null) {
      try {
        final errorData = jsonDecode(lastResponse.body);
        if (errorData['error'] != null) {
          final error = errorData['error'];
          final message = error['message'] ?? lastError ?? error.toString();
          final code = error['code'] ?? lastResponse.statusCode;
          errorMessage = "Error ($code): $message";
        }
      } catch (e) {
        errorMessage = "Error (${lastResponse.statusCode}): ${lastError ?? lastResponse.body}";
      }
    } else if (lastError != null) {
      errorMessage = "Error: $lastError";
    }
    
    setState(() {
      _messages.removeWhere((msg) => msg.isTemporary);
      _messages.add(Message(
        isUser: false,
        message: errorMessage,
        date: DateTime.now(),
      ));
      _isRequestInProgress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.dstATop),
            image: AssetImage('assets/images/botimage.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Messages(
                    isUser: message.isUser,
                    message: message.message,
                    date: DateFormat('HH:mm').format(message.date),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 15,
                    child: TextFormField(
                      style: TextStyle(color: Colors.white),
                      controller: _userInput,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        label: Text('Enter disease name', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    padding: EdgeInsets.all(12),
                    iconSize: 30,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(CircleBorder()),
                    ),
                    onPressed: _isRequestInProgress ? null : sendMessage,
                    icon: Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;
  final bool isTemporary;

  Message({required this.isUser, required this.message, required this.date, this.isTemporary = false});
}

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;

  const Messages({
    super.key,
    required this.isUser,
    required this.message,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 15).copyWith(
        left: isUser ? 100 : 10,
        right: isUser ? 10 : 100,
      ),
      decoration: BoxDecoration(
        color: isUser ? Colors.blueAccent : Colors.grey.shade400,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: isUser ? Radius.circular(10) : Radius.zero,
          topRight: Radius.circular(10),
          bottomRight: isUser ? Radius.zero : Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(fontSize: 16, color: isUser ? Colors.white : Colors.black),
          ),
          Text(
            date,
            style: TextStyle(fontSize: 10, color: isUser ? Colors.white : Colors.black),
          ),
        ],
      ),
    );
  }
}