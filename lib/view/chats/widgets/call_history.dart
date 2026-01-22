import 'package:chatx/model/message_model.dart';
import 'package:chatx/view/chats/chat_screen.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/time_format.dart';

class CallHistory extends StatelessWidget {
  const CallHistory({
    super.key,
    required this.isMe,
    required this.widget,
    required this.isMissed,
    required this.isVideo,
    required this.message,
  });
  final bool isMe;
  final ChatScreen widget;
  final bool isMissed;
  final bool isVideo;
  final MessageModel message;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundImage: widget.otherUser.photoUrl != null
                  ? NetworkImage(widget.otherUser.photoUrl!)
                  : null,
              child: widget.otherUser.photoUrl == null
                  ? Text(widget.otherUser.name[0].toLowerCase())
                  : Text("U"),
            ),
            SizedBox(width: 8),
          ],
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(50),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVideo ? Icons.videocam : Icons.call,
                  color: Colors.green,
                ),
                SizedBox(width: 8),
                Column(
                  children: [
                    Text(
                      isMissed
                          ? (isMe ? "Call not answered" : "Miss call")
                          : "${isVideo ? "Video" : "Audio"} call",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      formatMessageTime(message.timestamp),
                      style: TextStyle(
                        color: Colors.green.withAlpha(198),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if(isMe) ...[
            SizedBox(width: 8,)
          ]
        ],
      ),
    );
  }
}
