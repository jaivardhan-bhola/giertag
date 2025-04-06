import 'package:flutter/material.dart';

// Message model for SMS
class SmsMessage {
  final String sender;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  SmsMessage({
    required this.sender,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });
}

class Messages extends StatefulWidget {
  const Messages({super.key});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  // Sample messages from a tracking device
  final List<SmsMessage> messages = [
    SmsMessage(
      sender: "GierTag Device",
      content: "Location update: Child arrived at school safely at 8:15 AM",
      timestamp: DateTime.now().subtract(Duration(minutes: 30)),
    ),
    SmsMessage(
      sender: "GierTag Device",
      content: "Battery level: 75%. Device is functioning normally.",
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
    ),
    SmsMessage(
      sender: "GierTag Device",
      content: "Alert: Child left the designated safe zone at 3:45 PM",
      timestamp: DateTime.now().subtract(Duration(days: 1)),
    ),
  ];

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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.sms_rounded,
                      size: screenHeight * 0.035,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      'Read SMS',
                      style: TextStyle(
                        fontSize: screenHeight * 0.025,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sms_failed,
                          size: screenHeight * 0.1,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          "No messages found",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.01,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Icon(
                              Icons.sms,
                              color: Theme.of(context).colorScheme.onSurface, 
                            ),
                          ),
                          title: Text(
                            message.sender,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenHeight * 0.018,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                message.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: screenHeight * 0.016,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _formatMessageTime(message.timestamp),
                                style: TextStyle(
                                  fontSize: screenHeight * 0.014,
                                  color: Theme.of(context)
                                      .colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () => _viewMessageDetails(message),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _viewMessageDetails(SmsMessage message) {
    showModalBottomSheet( 
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        double screenHeight = MediaQuery.of(context).size.height;
        double screenWidth = MediaQuery.of(context).size.width;

        return Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
          height: screenHeight * 0.4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.sms,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: Text(
                      message.sender,
                      style: TextStyle(
                        fontSize: screenHeight * 0.025,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                message.content,
                style: TextStyle(fontSize: screenHeight * 0.02),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Received: ${_formatFullDate(message.timestamp)}',
                style: TextStyle(
                  fontSize: screenHeight * 0.018,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        );
      },
    );
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
