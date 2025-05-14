import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _userInput = TextEditingController();
  static const apiKey = "AIzaSyCgFagW7p8FXQueEXxg2lySg_RGA3I6F_8";
  final model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isRequestInProgress = false;

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

  Future<void> sendMessage() async {
    final message = _userInput.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(Message(isUser: true, message: message, date: DateTime.now()));
      _userInput.clear();
      _isRequestInProgress = true;
    });

    _scrollToBottom();

    // Improved health query for GroHealth app
    final content = [
      Content.text(
          "You are MediGuide, a professional health assistant for the GroHealth app. "
              "Analyze this health query: '$message'. "
              "If this is about a disease, provide a comprehensive yet concise response with these sections: "
              "1. Brief Overview (2-3 sentences explaining what it is) "
              "2. Key Symptoms (bullet points of main symptoms) "
              "3. Prevention & Precautions (practical steps) "
              "4. Treatment Options (mainstream medical treatments) "
              "5. Lifestyle Management (diet, exercise recommendations) "
              "6. When to See a Doctor (red flags that require medical attention) "
              "Format your response with clear headings and concise bullet points where appropriate. "
              "If this is not about a recognized health condition or is outside medical scope, "
              "respond with 'I'm not able to provide information on this topic. Please consult a healthcare professional or ask about a specific health condition.'"
      )
    ];

    // Adding a temporary "typing" message
    setState(() {
      _messages.add(Message(
          isUser: false,
          message: "Analyzing your health query...",
          date: DateTime.now(),
          isTemporary: true
      ));
    });

    _scrollToBottom();

    try {
      final response = await model.generateContent(content);

      setState(() {
        // Remove the temporary message
        _messages.removeWhere((msg) => msg.isTemporary);
        _messages.add(Message(isUser: false, message: response.text ?? "", date: DateTime.now()));
        _isRequestInProgress = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        // Remove the temporary message
        _messages.removeWhere((msg) => msg.isTemporary);
        _messages.add(Message(
            isUser: false,
            message: "Sorry, I encountered an error processing your request. Please try again later.",
            date: DateTime.now()
        ));
        _isRequestInProgress = false;
      });

      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: TColors.primary,
        title: const Text(
          "MediGuide - GroHealth",
          style: TextStyle(
            color: TColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: TColors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: TColors.background,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "About MediGuide",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: TColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "MediGuide provides health information for educational purposes only. "
                            "Always consult a healthcare professional for medical advice.",
                        style: TextStyle(
                          fontSize: 16,
                          color: TColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.accent,
                          foregroundColor: TColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Got it"),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      // Wrap the body in a ResizeToAvoidBottomInset to handle keyboard overflow
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                TColors.background,
                TColors.background2,
              ],
            ),
          ),
          // Wrap the main Column in a KeyboardDismissOnTap
          child: GestureDetector(
            onTap: () {
              // Dismiss keyboard when tapping outside of text field
              FocusScope.of(context).unfocus();
            },
            child: Column(
              children: [
                // Header info card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TColors.secondary.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: TColors.accent.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: TColors.accent,
                        radius: 20,
                        child: Icon(Icons.health_and_safety, color: TColors.white),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Ask about any health condition or disease for professional guidance",
                          style: TextStyle(
                            color: TColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms),

                // Messages list with Expanded to take available space
                Expanded(
                  child: _messages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 8,
                      // Add bottom padding to ensure last message is visible above keyboard
                      bottom: 8,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return MessageBubble(
                        isUser: message.isUser,
                        message: message.message,
                        date: DateFormat('HH:mm').format(message.date),
                        isTemporary: message.isTemporary,
                      ).animate().fadeIn(
                        duration: 300.ms,
                        delay: 100.ms,
                      ).slideY(
                        begin: 0.1,
                        duration: 300.ms,
                        curve: Curves.easeOutQuad,
                      );
                    },
                  ),
                ),

                // Input area - now uses Padding instead of Container for layout
                Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    // Add bottom padding to account for any system UI at the bottom of the screen
                    bottom: MediaQuery.of(context).viewInsets.bottom > 0
                        ? 12
                        : 12 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: TColors.background3,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: TColors.greyDark.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: TColors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: TextField(
                              controller: _userInput,
                              textCapitalization: TextCapitalization.sentences,
                              style: const TextStyle(
                                color: TColors.textPrimary,
                                fontSize: 16,
                              ),
                              // Set to false to allow scrolling of multiline input
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.send,
                              decoration: InputDecoration(
                                hintText: 'Type a health condition...',
                                hintStyle: TextStyle(
                                  color: TColors.placeholder,
                                  fontSize: 16,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                border: InputBorder.none,
                                suffixIcon: _userInput.text.isNotEmpty
                                    ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  color: TColors.grey,
                                  onPressed: () {
                                    setState(() {
                                      _userInput.clear();
                                    });
                                  },
                                )
                                    : null,
                              ),
                              onChanged: (value) {
                                // Forces a rebuild to show/hide the clear button
                                setState(() {});
                              },
                              onSubmitted: (_) {
                                if (!_isRequestInProgress) sendMessage();
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [TColors.primary, TColors.accent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: TColors.accent.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(25),
                              onTap: _isRequestInProgress ? null : sendMessage,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: _isRequestInProgress
                                    ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: TColors.white,
                                    strokeWidth: 2.0,
                                  ),
                                )
                                    : const Icon(
                                  Icons.send_rounded,
                                  color: TColors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: TColors.secondary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: TColors.accent.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: const Icon(
                Icons.medical_information,
                size: 50,
                color: TColors.accent,
              ),
            ).animate().scale(
              duration: 600.ms,
              curve: Curves.elasticOut,
            ),
            const SizedBox(height: 20),
            const Text(
              "Welcome to MediGuide",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: TColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Ask me about any health condition, symptoms, or disease for reliable information",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: TColors.textSecondary,
                ),
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
            const SizedBox(height: 40),
            _buildSuggestionChips().animate().fadeIn(
              delay: 800.ms,
              duration: 600.ms,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChips() {
    final suggestions = [
      "Diabetes",
      "Hypertension",
      "Asthma",
      "Migraine",
      "Arthritis",
      "Anxiety"
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((suggestion) {
        return ActionChip(
          label: Text(suggestion),
          backgroundColor: TColors.background3,
          shadowColor: TColors.accent.withOpacity(0.3),
          elevation: 3,
          labelStyle: const TextStyle(color: TColors.accent),
          onPressed: () {
            setState(() {
              _userInput.text = suggestion;
            });
            sendMessage();
          },
        );
      }).toList(),
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

class MessageBubble extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;
  final bool isTemporary;

  const MessageBubble({
    super.key,
    required this.isUser,
    required this.message,
    required this.date,
    this.isTemporary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          bottom: 12,
          left: isUser ? 50 : 0,
          right: isUser ? 0 : 50,
        ),
        decoration: BoxDecoration(
          color: isUser ? TColors.accent : TColors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isUser ? const Radius.circular(18) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: (isUser ? TColors.accent : TColors.greyLight).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isTemporary)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      color: isUser ? TColors.white : TColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isUser ? TColors.white : TColors.accent,
                    ),
                  ),
                ],
              )
            else
              MessageContent(message: message, isUser: isUser),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 11,
                    color: isUser ? TColors.white.withOpacity(0.8) : TColors.greyDark.withOpacity(0.7),
                  ),
                ),
                if (isUser) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 12,
                    color: TColors.white.withOpacity(0.8),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MessageContent extends StatelessWidget {
  final String message;
  final bool isUser;

  const MessageContent({
    super.key,
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    // Parse the message to identify headers and bullet points
    final lines = message.split('\n');
    List<Widget> contentWidgets = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.isEmpty) continue;

      // Check if line is a header (starts with # or has : at the end)
      if (line.startsWith('#') ||
          (line.endsWith(':') && !line.contains('-')) ||
          (i > 0 && lines[i-1].isEmpty && i < lines.length-1 && lines[i+1].isEmpty) ||
          line.toUpperCase() == line) {

        contentWidgets.add(
          Padding(
            padding: EdgeInsets.only(top: contentWidgets.isEmpty ? 0 : 10, bottom: 5),
            child: Text(
              line.replaceAll('#', '').trim(),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isUser ? TColors.white : TColors.textPrimary,
              ),
            ),
          ),
        );
      }
      // Check if line is a bullet point
      else if (line.startsWith('•') || line.startsWith('-') || line.startsWith('*')) {
        contentWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isUser ? TColors.white : TColors.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    line.replaceFirst(RegExp(r'^[•\-*]\s*'), ''),
                    style: TextStyle(
                      fontSize: 15,
                      color: isUser ? TColors.white : TColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // Regular text
      else {
        contentWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 3),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 15,
                color: isUser ? TColors.white : TColors.textPrimary,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contentWidgets,
    );
  }
}