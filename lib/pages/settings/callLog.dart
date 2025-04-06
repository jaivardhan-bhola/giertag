import 'package:flutter/material.dart';

// Model class for call log entries
class CallLogEntry {
  final String name;
  final String phoneNumber;
  final DateTime timestamp;
  final CallType callType;
  final Duration? duration;

  CallLogEntry({
    required this.name,
    required this.phoneNumber,
    required this.timestamp,
    required this.callType,
    this.duration,
  });
}

enum CallType { incoming, outgoing, missed }

class Calllog extends StatefulWidget {
  const Calllog({super.key});

  @override
  State<Calllog> createState() => _CalllogState();
}

class _CalllogState extends State<Calllog> {
  // Sample call log data
  final List<CallLogEntry> callLogs = [
    CallLogEntry(
      name: "John Smith",
      phoneNumber: "(555) 123-4567",
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      callType: CallType.incoming,
      duration: Duration(minutes: 5, seconds: 32),
    ),
    CallLogEntry(
      name: "Sarah Johnson",
      phoneNumber: "(555) 987-6543",
      timestamp: DateTime.now().subtract(Duration(hours: 5)),
      callType: CallType.outgoing,
      duration: Duration(minutes: 2, seconds: 18),
    ),
    CallLogEntry(
      name: "Unknown",
      phoneNumber: "(555) 456-7890",
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      callType: CallType.missed,
      duration: null,
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
                SizedBox(width: screenWidth * 0.02),
                Text(
                  'View call log',
                  style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Call logs list
          Expanded(
            child: callLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone_missed,
                          size: 56,
                          color: Colors.grey,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          "No call logs found",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: callLogs.length,
                    itemBuilder: (context, index) {
                      final call = callLogs[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.01,
                        ),
                        child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getCallTypeColor(call.callType),
                              child: Icon(
                                _getCallTypeIcon(call.callType),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              call.name,
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
                                  call.phoneNumber,
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.016,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.005),
                                Row(
                                  children: [
                                    Text(
                                      _formatCallTime(call.timestamp),
                                      style: TextStyle(
                                        fontSize: screenHeight * 0.014,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    if (call.duration != null)
                                      Text(
                                        _formatDuration(call.duration!),
                                        style: TextStyle(
                                          fontSize: screenHeight * 0.014,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            onTap: () => {}),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getCallTypeColor(CallType type) {
    switch (type) {
      case CallType.incoming:
        return Colors.green;
      case CallType.outgoing:
        return Colors.blue;
      case CallType.missed:
        return Colors.red;
    }
  }

  IconData _getCallTypeIcon(CallType type) {
    switch (type) {
      case CallType.incoming:
        return Icons.call_received;
      case CallType.outgoing:
        return Icons.call_made;
      case CallType.missed:
        return Icons.call_missed;
    }
  }

  String _formatCallTime(DateTime timestamp) {
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
