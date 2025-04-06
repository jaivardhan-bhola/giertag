import 'package:flutter/material.dart';

// Message model to represent chat messages
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class Customersupport extends StatefulWidget {
  const Customersupport({super.key});

  @override
  State<Customersupport> createState() => _CustomersupportState();
}

class _CustomersupportState extends State<Customersupport> {
  // Controller for the message input field
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // List of chat messages
  List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! How can we help you today?",
      isUser: false,
      timestamp: DateTime.now().subtract(Duration(minutes: 5)),
    ),
    ChatMessage(
      text: "I'm having issues with my recent order.",
      isUser: true,
      timestamp: DateTime.now().subtract(Duration(minutes: 4)),
    ),
    ChatMessage(
      text:
          "I'm sorry to hear that. Could you please provide your order number?",
      isUser: false,
      timestamp: DateTime.now().subtract(Duration(minutes: 3)),
    ),
    ChatMessage(
      text: "Sure, it's GT12345.",
      isUser: true,
      timestamp: DateTime.now().subtract(Duration(minutes: 2)),
    ),
    ChatMessage(
      text: "Thank you! I'm checking your order details now.",
      isUser: false,
      timestamp: DateTime.now().subtract(Duration(minutes: 1)),
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Send a new message
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: _messageController.text.trim(),
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _messageController.clear();
    });

    // Scroll to the bottom of the chat
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Simulate a response after a short delay
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                "Thanks for your message. Our support team will get back to you shortly.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });

      // Scroll to the bottom again after the response
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  // Format timestamp to show only the time
  String _formatTime(DateTime timestamp) {
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text('Gier',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: screenHeight * 0.03)),
            Text('Tag',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenHeight * 0.03)),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.history),
            label: Text("History"),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat header
          Container(
            padding: EdgeInsets.all(screenHeight * 0.02),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(Icons.support_agent, color: Colors.white),
                ),
                SizedBox(width: screenWidth * 0.02),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Customer Support",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight * 0.025,
                      ),
                    ),
                    Text(
                      "Typically replies within 1 hour",
                      style: TextStyle(
                        fontSize: screenHeight * 0.018,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(screenHeight * 0.02),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth * 0.75,
                    ),
                    margin: EdgeInsets.only(
                      bottom: screenHeight * 0.01,
                      left: message.isUser ? screenWidth * 0.2 : 0,
                      right: message.isUser ? 0 : screenWidth * 0.2,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.04,
                    ),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.text,
                          style: TextStyle(
                            color: message.isUser
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            fontSize: screenHeight * 0.012,
                            color: message.isUser
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimary
                                    .withOpacity(0.7)
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Message input
          Container(
            padding: EdgeInsets.all(screenHeight * 0.01),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.attach_file),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceVariant,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
