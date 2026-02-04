import 'dart:ui';
import 'package:chatx/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/time_format.dart';
import 'message_status_icon.dart';
import 'package:chatx/model/message_model.dart';

class MessageAndImageDisplay extends StatelessWidget {
  MessageAndImageDisplay({
    super.key,
    required this.isMe,
    required this.message,
    required this.onDelete,
    required this.onReact,
    required this.otherUserName,
    required this.otherUserPhoto,
    required this.otherUserUid,
  });

  final bool isMe;
  final MessageModel message;
  final Future<void> Function() onDelete;
  final Future<void> Function(String? emoji) onReact;
  final String otherUserName;
  final String? otherUserPhoto;
  final String otherUserUid;

  final GlobalKey _bubbleKey = GlobalKey();

  static const double _menuWidth = 240;
  static const double _menuHeight = 300;
  static const double _reactionBarHeight = 56;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundImage:
                  otherUserPhoto != null ? NetworkImage(otherUserPhoto!) : null,
              child: otherUserPhoto == null
                  ? Text(otherUserName[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(child: _messageWithReaction(context)),
        ],
      ),
    );
  }

  Widget _messageWithReaction(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _bubble(context),
        if (message.reaction != null && message.reaction!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              top: 2,
              left: isMe ? 0 : 8,
              right: isMe ? 8 : 0,
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.15),
                  ),
                ],
              ),
              child: Text(
                message.reaction!,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
      ],
    );
  }

  /// REAL bubble (has GlobalKey)
  Widget _bubble(BuildContext context) {
    return GestureDetector(
      key: _bubbleKey,
      onLongPress: () => _showPopup(context),
      child: _bubbleContent(context),
    );
  }

  /// ✅ UI-only bubble (NO GlobalKey) — used for overlay preview
  Widget _bubbleContent(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 6),
        decoration: BoxDecoration(
     color: isMe ? kPrimary : Colors.grey.shade300,

          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft:
                isMe ? const Radius.circular(18) : const Radius.circular(6),
            bottomRight:
                isMe ? const Radius.circular(6) : const Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              color: Colors.black.withOpacity(0.12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.message,
              style: TextStyle(
                fontSize: 16,
                height: 1.3,
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatMessageTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : Colors.black54,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  buildMessageStatusIcon(message, otherUserUid),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// POPUP 
void _showPopup(BuildContext context) {
  final overlay = Overlay.of(context);
  final ctx = _bubbleKey.currentContext;
  if (ctx == null || overlay == null) return;

  final box = ctx.findRenderObject() as RenderBox;
  final pos = box.localToGlobal(Offset.zero);
  final size = box.size;

  final media = MediaQuery.of(context);
  final screenWidth = media.size.width;
  final screenHeight = media.size.height;


  double bubbleTop = pos.dy;
  double reactionTop = bubbleTop + size.height + 8;
  double menuTop = reactionTop + _reactionBarHeight + 8;

  final totalPopupHeight =
      size.height + 8 + _reactionBarHeight + 8 + _menuHeight;


  double shiftUp = 0;
  final maxBottom = screenHeight - 16;

  if (bubbleTop + totalPopupHeight > maxBottom) {
    shiftUp = (bubbleTop + totalPopupHeight) - maxBottom;
  }

  bubbleTop -= shiftUp;
  reactionTop -= shiftUp;
  menuTop -= shiftUp;

  // Horizontal clamp
  final left = pos.dx.clamp(
    8.0,
    screenWidth - _menuWidth - 8,
  );

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => Stack(
      children: [
        // Background blur
        GestureDetector(
          onTap: () => entry.remove(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),
        ),

     
        Positioned(
          left: pos.dx,
          top: bubbleTop,
          width: size.width,
          height: size.height,
          child: Material(
            color: Colors.transparent,
            child: _bubbleContent(context),
          ),
        ),

        // Reaction bar
        Positioned(
          left: left,
          top: reactionTop,
          child: _reactionBar(entry),
        ),

        // Options menu
        Positioned(
          left: left,
          top: menuTop,
          child: _optionsCard(entry),
        ),
      ],
    ),
  );

  overlay.insert(entry);
}


Widget _reactionBar(OverlayEntry entry) {
  final emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

  return Material(
    color: Colors.transparent,
    child: Transform.translate(
      offset: const Offset(-60, 0), 
      child: Container(
        height: _reactionBarHeight,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              blurRadius: 25,
              color: Colors.black.withOpacity(0.2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: emojis.map((e) {
            return GestureDetector(
              onTap: () async {
                await onReact(message.reaction == e ? null : e);
                entry.remove();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  e,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ),
  );
}

  Widget _optionsCard(OverlayEntry entry) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: _menuWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              blurRadius: 30,
              color: Colors.black.withOpacity(0.18),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _tile(Icons.reply, 'Reply', () => entry.remove()),
            _tile(Icons.forward, 'Forward', () => entry.remove()),
            _tile(Icons.copy, 'Copy', () {
              Clipboard.setData(ClipboardData(text: message.message));
              entry.remove();
            }),
            _tile(Icons.delete_outline, 'Delete', () async {
              entry.remove();
              await onDelete();
            }, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    IconData icon,
    String text,
    VoidCallback onTap, {
    Color color = Colors.black87,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 22, color: color),
      title: Text(text, style: TextStyle(fontSize: 16, color: color)),
      onTap: onTap,
    );
  }
}
