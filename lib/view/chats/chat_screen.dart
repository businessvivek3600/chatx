import 'dart:async';
import 'dart:io';

import 'package:chatx/core/utils/colors.dart';
import 'package:chatx/providers/provider.dart';
import 'package:chatx/view/chats/widgets/audio_video_call_button.dart';
import 'package:chatx/view/chats/widgets/call_history.dart';
import 'package:chatx/view/chats/widgets/message_and_image_display.dart';
import 'package:chatx/view/chats/widgets/user_chat_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/user_model.dart';
import 'widgets/image_preview_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.chatId, required this.otherUser});

  final String chatId;
  final UserModel otherUser;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _textFieldFocusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();

  Timer? _typingDebounceTimer;
  Timer? _readStatusTimer;
  bool _isTyping = false;

  // -------------------- UPDATE REACTION --------------------
  Future<void> updateReaction(String messageId, String? emoji) async {
    await ref
        .read(chatServiceProvider)
        .updateMessageReaction(
          chatId: widget.chatId,
          messageId: messageId,
          reaction: emoji,
        );
  }

  // -------------------- DELETE MESSAGE --------------------
  Future<void> deleteMessage(String messageId) async {
    await ref
        .read(chatServiceProvider)
        .deleteMessage(chatId: widget.chatId, messageId: messageId);
  }

  // -------------------- Typing --------------------
  void _handleTextChange(String text) {
    _typingDebounceTimer?.cancel();

    if (text.trim().isNotEmpty && !_isTyping) {
      _isTyping = true;
      ref.read(typingProvider(widget.chatId).notifier).setTyping(true);
    }

    _typingDebounceTimer = Timer(const Duration(seconds: 2), () {
      if (_isTyping) {
        _isTyping = false;
        ref.read(typingProvider(widget.chatId).notifier).setTyping(false);
      }
    });
  }

  // -------------------- Lifecycle --------------------
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _markAsRead());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _textFieldFocusNode.dispose();
    _typingDebounceTimer?.cancel();
    _readStatusTimer?.cancel();
    super.dispose();
  }

  // -------------------- Messaging --------------------
  Future<void> sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    await ref
        .read(chatServiceProvider)
        .sendMessage(chatId: widget.chatId, message: text);

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _markAsRead() async {
    _readStatusTimer?.cancel();
    _readStatusTimer = Timer(
      const Duration(milliseconds: 300),
      () => ref.read(chatServiceProvider).markMessageAsRead(widget.chatId),
    );
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    final chatService = ref.read(chatServiceProvider);
    final user = widget.otherUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        elevation: 0.6,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: UserChatProfile(widget: widget),
        actions: [
          actionButton(false, user.uid, user.name, ref, widget.chatId),
          actionButton(true, user.uid, user.name, ref, widget.chatId),
        ],
      ),

      body: Column(
        children: [
          // -------------------- MESSAGES --------------------
          Expanded(
            child: StreamBuilder(
              stream: chatService.getChatMessages(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      "No messages yet",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe =
                        msg.senderId == FirebaseAuth.instance.currentUser!.uid;

                    return msg.type == 'call'
                        ? CallHistory(
                            isMe: isMe,
                            widget: widget,
                            isMissed: msg.callStatus == 'missed',
                            isVideo: msg.callType == 'video',
                            message: msg,
                          )
                        : MessageAndImageDisplay(
                            isMe: isMe,
                            message: msg,
                            otherUserName: widget.otherUser.name,
                            otherUserPhoto: widget.otherUser.photoUrl,
                            otherUserUid: widget.otherUser.uid,
                            onDelete: () => deleteMessage(msg.messageId),

                            // 🔥 REQUIRED FOR EMOJI POPUP
                            onReact: (emoji) =>
                                updateReaction(msg.messageId, emoji),
                          );
                  },
                );
              },
            ),
          ),

          // -------------------- INPUT BAR --------------------
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black.withOpacity(0.06),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo, color: Colors.grey),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),

                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _textFieldFocusNode,
                      minLines: 1,
                      maxLines: 5,
                      onChanged: _handleTextChange,
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        filled: true,
                        fillColor: const Color(0xFFF1F3F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.grey),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),

                  IconButton(
                    icon: const Icon(Icons.mic, color: Colors.grey),
                    onPressed: () {},
                  ),

                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: kPrimary),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Image Picker --------------------
  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      final result = await Navigator.push<ImagePreviewResult>(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => ImagePreviewScreen(imageFile: File(picked.path)),
        ),
      );

      if (result != null) {
        await ref
            .read(chatServiceProvider)
            .sendImageWithUpload(
              chatId: widget.chatId,
              imageFile: result.imageFile,
              caption: result.caption,
            );
      }
    }
  }
}

// -------------------- Image Result --------------------
class ImagePreviewResult {
  final File imageFile;
  final String caption;

  ImagePreviewResult({required this.imageFile, required this.caption});
}
