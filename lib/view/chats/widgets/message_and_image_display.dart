import 'package:chatx/core/utils/colors.dart';
import 'package:chatx/model/message_model.dart';
import 'package:chatx/view/chats/chat_screen.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/time_format.dart';
import 'image_full_screen.dart';
import 'message_status_icon.dart';

class MessageAndImageDisplay extends StatelessWidget {
  const MessageAndImageDisplay({
    super.key,
    required this.isMe,
    required this.widget,
    required this.message,
  });
  final bool isMe;
  final ChatScreen widget;
  final MessageModel message;
  @override
  Widget build(BuildContext context) {
    final image = widget.otherUser.photoUrl;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundImage: image != null ? NetworkImage(image) : null,
              child: image == null
                  ? Text(widget.otherUser.name[0].toLowerCase())
                  : Text("U"),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: message.type == 'image' ? 0 : 10,
                vertical: message.type == 'image' ? 0 : 10,
              ),
              decoration: BoxDecoration(
                color: isMe ? Colors.blueAccent : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///image display
                  if (message.type == 'image' && message.imageUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: GestureDetector(
                        onTap: () {
                          showFullScreenImage(message.imageUrl!, context);
                        },
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: 300,
                            maxWidth: 250,
                          ),
                          child: Image.network(
                            message.imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                height: 200,
                                width: 200,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey.shade300,
                                child: Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    if(message.message.isNotEmpty) const SizedBox(height: 8,),
                  ],
                  const SizedBox(height: 8,),
                  /// Text message (for regular message or image captions
                  if (message.message.isNotEmpty)
                    Padding(
                      padding: message.type == 'image'?
                      const EdgeInsets.only(left: 10) : EdgeInsets.zero,
                      child: Text(
                        message.message,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  Padding(
                    padding:
                  message.type == 'image'?
                    const EdgeInsets.only(left: 20,bottom: 5) : EdgeInsets.zero,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(width: 4),
                        Text(
                          formatMessageTime(message.timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),

                        if (isMe) ...[
                          SizedBox(width: 4),

                          ///Message status icon
                          buildMessageStatusIcon(message, widget.otherUser.uid)
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 4,),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(),
        ],
      ),
    );
  }
}
