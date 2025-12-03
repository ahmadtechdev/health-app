import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _userInput = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  static const apiKey = "AIzaSyATg46kzkzAYCqBLM9KDEscqopJnuU0k44";
  
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
  
  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(Message(
      isUser: false,
      message: "Hello! I'm MediGuide, your AI health assistant. 👋\n\nI can provide information about diseases including:\n• Precautions\n• Medicines\n• Cures\n• Exercises\n\nPlease enter the name of a disease to get started.",
      date: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _userInput.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  String _getApiUrl(String modelName, {bool useBeta = false}) {
    final version = useBeta ? 'v1beta' : 'v1';
    return "https://generativelanguage.googleapis.com/$version/models/$modelName:generateContent";
  }

  Future<void> sendMessage() async {
    final message = _userInput.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(Message(isUser: true, message: message, date: DateTime.now()));
      _userInput.clear();
      _isRequestInProgress = true;
    });
    _scrollToBottom();

    final prompt = "You are a medical assistant. Upon receiving the name of a human health disease, provide comprehensive information including:\n"
        "1. Precautions\n"
        "2. Medicines (with brief descriptions)\n"
        "3. Cures/Treatments\n"
        "4. Recommended Exercises\n\n"
        "Format the response with clear headings using # for main headings and - for bullet points. "
        "Each section should have 2 to 10 lines of information. "
        "The disease is: $message. "
        "If the input is not a recognized disease, respond with 'Unrecognized disease. Please enter a valid disease name.'";

    // Adding a temporary "MediGuide is writing" message
    setState(() {
      _messages.add(Message(
        isUser: false,
        message: "MediGuide is analyzing...",
        date: DateTime.now(),
        isTemporary: true,
      ));
    });
    _scrollToBottom();

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
          headers: {'Content-Type': 'application/json'},
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
          _workingModel = modelName;
          
          try {
            final responseData = jsonDecode(response.body);
            debugPrint('Response data keys: ${responseData.keys}');
            
            String responseText = "Sorry, I couldn't generate a response.";
            
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
              responseText = responseData['text'] as String;
            } else {
              debugPrint('Unexpected response format: ${response.body}');
            }

            setState(() {
              _messages.removeWhere((msg) => msg.isTemporary);
              _messages.add(Message(isUser: false, message: responseText, date: DateTime.now()));
              _isRequestInProgress = false;
            });
            _scrollToBottom();
            return;
          } catch (e) {
            debugPrint('Error parsing response: $e');
            debugPrint('Response body: ${response.body}');
            lastError = "Failed to parse response: $e";
            continue;
          }
        } else {
          debugPrint('Response body: ${response.body}');
          try {
            final errorData = jsonDecode(response.body);
            if (errorData['error'] != null) {
              final error = errorData['error'];
              final message = error['message'] ?? error.toString();
              lastError = message;
              debugPrint('API Error for $modelName: $message');
              
              if (response.statusCode == 429) {
                debugPrint('Quota exceeded for $modelName, trying next model...');
                continue;
              }
              
              if (response.statusCode == 404) {
                continue;
              } else if (response.statusCode == 400 || response.statusCode == 403 || response.statusCode == 401) {
                break;
              }
            }
          } catch (e) {
            debugPrint('Could not parse error response: $e');
            lastError = response.body;
            if (response.statusCode == 404 || response.statusCode == 429) {
              continue;
            } else {
              break;
            }
          }
        }
      } catch (e) {
        debugPrint('Exception caught for $modelName: $e');
        lastError = e.toString();
        continue;
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
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        title: const Text(
          'MediGuide Assistant',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: TColors.textPrimary,
          ),
        ),
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [TColors.primary, TColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: TColors.accent.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        color: TColors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Health Assistant',
                            style: TextStyle(
                              color: TColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Get instant medical information',
                            style: TextStyle(
                              color: TColors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Messages List
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: TColors.accent.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start a conversation',
                          style: TextStyle(
                            fontSize: 18,
                            color: TColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return ChatMessage(
                        isUser: message.isUser,
                        message: message.message,
                        date: DateFormat('HH:mm').format(message.date),
                        isTemporary: message.isTemporary,
                      );
                    },
                  ),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TColors.white,
              boxShadow: [
                BoxShadow(
                  color: TColors.greyLight.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _userInput,
                      style: const TextStyle(
                        color: TColors.textPrimary,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter disease name...',
                        hintStyle: TextStyle(color: TColors.placeholder),
                        filled: true,
                        fillColor: TColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: TColors.background3),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: TColors.background3),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(color: TColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onSubmitted: (_) {
                        if (!_isRequestInProgress) sendMessage();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: TColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: TColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: const EdgeInsets.all(12),
                      iconSize: 24,
                      color: TColors.white,
                      onPressed: _isRequestInProgress ? null : sendMessage,
                      icon: _isRequestInProgress
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(TColors.white),
                              ),
                            )
                          : const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;
  final bool isTemporary;

  Message({
    required this.isUser,
    required this.message,
    required this.date,
    this.isTemporary = false,
  });
}

class ChatMessage extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;
  final bool isTemporary;

  const ChatMessage({
    super.key,
    required this.isUser,
    required this.message,
    required this.date,
    this.isTemporary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [TColors.primary, TColors.accent],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: TColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.medical_services,
                color: TColors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? TColors.primary : TColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isUser ? TColors.primary : TColors.greyLight).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isTemporary)
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isUser ? TColors.white : TColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          message,
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: isUser
                                ? TColors.white.withOpacity(0.8)
                                : TColors.textSecondary,
                          ),
                        ),
                      ],
                    )
                  else
                    _buildFormattedMessage(),
                  const SizedBox(height: 8),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 11,
                      color: isUser
                          ? TColors.white.withOpacity(0.7)
                          : TColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: TColors.accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: TColors.accent.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: TColors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormattedMessage() {
    final lines = message.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Check for headings (lines starting with # or numbered headings)
      if (line.trim().startsWith('#') || 
          RegExp(r'^\d+\.\s+[A-Z]').hasMatch(line.trim())) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              line.trim().replaceAll('#', '').trim(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isUser ? TColors.white : TColors.textPrimary,
              ),
            ),
          ),
        );
      } else if (line.trim().startsWith('-') || line.trim().startsWith('•')) {
        // Bullet points
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    fontSize: 16,
                    color: isUser ? TColors.white : TColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    line.trim().replaceAll(RegExp(r'^[-•]\s*'), ''),
                    style: TextStyle(
                      fontSize: 15,
                      color: isUser ? TColors.white : TColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Regular text
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              line.trim(),
              style: TextStyle(
                fontSize: 15,
                color: isUser ? TColors.white : TColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
