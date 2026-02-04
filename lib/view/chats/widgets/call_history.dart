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
    /// 🔴 MISSED + INCOMING ONLY
    final bool isMissedIncoming = isMissed && !isMe;

    final Color callColor =
        isMissedIncoming ? Colors.red : Colors.green;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // ---------------- AVATAR (incoming only) ----------------
          if (!isMe) ...[
            CircleAvatar(
              backgroundImage: widget.otherUser.photoUrl != null
                  ? NetworkImage(widget.otherUser.photoUrl!)
                  : null,
              child: widget.otherUser.photoUrl == null
                  ? Text(
                      widget.otherUser.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],

          // ---------------- CALL BUBBLE ----------------
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: callColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: callColor, width: 1.6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVideo ? Icons.videocam : Icons.call,
                  color: callColor,
                  size: 18,
                ),
                const SizedBox(width: 8),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMissedIncoming
                          ? "Missed ${isVideo ? "video" : "audio"} call"
                          : "${isVideo ? "Video" : "Audio"} call",
                      style: TextStyle(
                        color: callColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatMessageTime(message.timestamp),
                      style: TextStyle(
                        color: callColor.withOpacity(0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
