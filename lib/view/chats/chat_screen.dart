import 'dart:async';
import 'dart:io';

import 'package:chatx/core/utils/app_utils.dart';
import 'package:chatx/providers/provider.dart';
import 'package:chatx/view/chats/widgets/audio_video_call_button.dart';
import 'package:chatx/view/chats/widgets/call_history.dart';
import 'package:chatx/view/chats/widgets/message_and_image_display.dart';
import 'package:chatx/view/chats/widgets/user_chat_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/helper/date_time_helper.dart';
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
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  final FocusNode _textFieldFocusNode = FocusNode();
  Timer? _typingTimer;
  bool _isCurrentlyTyping = false;
  bool _isTextFieldFocused = false;
  Timer? _typingDebounceTimer;

  // typing indicator handler
  void _handleTextChange(String text) {
    // cancel previous tier
    _typingDebounceTimer?.cancel();
    if (text.trim().isNotEmpty && _isTextFieldFocused) {
      if (!_isCurrentlyTyping) {
        _isCurrentlyTyping = true;
        ref.read(typingProvider(widget.chatId).notifier).setTyping(true);
      }
      // set timer to store typing after 2 second of no typing
      _typingDebounceTimer = Timer(Duration(seconds: 2), () {
        _handleTypingStop();
      });
    } else {
      _handleTypingStop();
    }
  }

  void _handleTypingStart() {
    if (!_isCurrentlyTyping) {
      _isCurrentlyTyping = true;
      ref.read(typingProvider(widget.chatId).notifier).setTyping(true);
    }
    // cancel any existing timer
    _typingTimer?.cancel();
  }

  void _handleTypingStop() {
    if (!_isCurrentlyTyping) {
      _isCurrentlyTyping = true;
      ref.read(typingProvider(widget.chatId).notifier).setTyping(false);
    }
    _typingTimer?.cancel();
  }

  void _handleTextFieldFocus() {
    _isTextFieldFocused = true;
    // start typing indicator if there's already text
    if (_messageController.text.trim().isEmpty) {
      _handleTypingStart();
    }
  }

  void _handleTextFieldUnfocus() {
    _isTextFieldFocused = false;
    _handleTypingStop();
  }

  @override
  void initState() {
    super.initState();
    // attach listener to track focus events on text field
    _textFieldFocusNode.addListener(() {
      if (_textFieldFocusNode.hasFocus) {
        _handleTextFieldFocus();
      } else {
        _handleTextFieldUnfocus();
      }
    });

    /// Mark messages as read when chat screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markAsRead();
    });
  }

  ///Send text Message
  Future<void> sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    _messageController.clear();
    //Stop typing when message is sent
    _handleTypingStop();
    // reset the flag to allow making as read for response
    final chatServices = ref.read(chatServiceProvider);
    final result = await chatServices.sendMessage(
      chatId: widget.chatId,
      message: message,
    );

    if (result != 'success') {
      if (!mounted) return;
      showAppSnackbar(
        context: context,
        type: SnackbarType.error,
        description: "Failed to send message: $result",
      );
    }
    //auto scroll to bottom after sending message
    WidgetsBinding.instance.addPersistentFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Timer? _readStatusTimer;
  List<String> unreadMessagesIds = [];
  // message read handler
  Future<void> _markAsRead() async {
    _readStatusTimer?.cancel();
    _readStatusTimer = Timer(const Duration(milliseconds: 300), () async {
      final chatServices = ref.read(chatServiceProvider);
      await chatServices.markMessageAsRead(widget.chatId);
    });
  }

  /// auto scroll to
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _readStatusTimer?.cancel();
    _textFieldFocusNode.dispose();
    _typingTimer?.cancel();
    if (_isCurrentlyTyping) {
      ref.read(typingProvider(widget.chatId).notifier).setTyping(false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatServices = ref.read(chatServiceProvider);
    final user = widget.otherUser;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        backgroundColor: Colors.white,
        forceMaterialTransparency: true,
        iconTheme: IconThemeData(color: Colors.black),
        title: UserChatProfile(widget: widget),
        actions: [
          ///Audio call
          actionButton(false, user.uid, user.name, ref, widget.chatId),

          ///Video call
          actionButton(true, user.uid, user.name, ref, widget.chatId),

          /// pop up menu  -> unfriend option
          PopupMenuButton(
            icon: Icon(Icons.more_vert_outlined),
            color: Colors.white,
            onSelected: (value) async {
              if (value == 'unfriend') {
                final result = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Unfriend'),
                    content: Text(
                      'Are you sure you want to unfriend ${widget.otherUser.name}',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Unfriend'),
                      ),
                    ],
                  ),
                );
                // if confirmed -> unfriend
                if (result == true) {
                  final unfriend = await ref
                      .read(chatServiceProvider)
                      .unfriendUser(widget.chatId, widget.otherUser.uid);

                  if (unfriend == 'success' && context.mounted) {
                    Navigator.pop(context);
                    showAppSnackbar(
                      context: context,
                      type: SnackbarType.success,
                      description: "Your Friendship is Disconnect",
                    );
                  }
                }
              }
            },

            itemBuilder: (context) => [
              PopupMenuItem(value: 'unfriend', child: Text('Unfriend')),
            ],
          ),
        ],
      ),
      // chat body
      body: Column(
        children: [
          //message section
          Expanded(
            child: StreamBuilder(
              stream: chatServices.getChatMessages(widget.chatId),
              builder: (context, snapshot) {
                // loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final message = snapshot.data ?? [];
                if (snapshot.hasData && message.isNotEmpty) {
                  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
                  final hasUnreadMessages = message.any(
                    (msg) =>
                        msg.senderId != currentUserId &&
                        !(msg.readBy?.containsKey(currentUserId) ?? false),
                  );
                }
                // empty chat ui
                if (message.isEmpty) {
                  return Center(
                    child: Text(
                      "No messages yet. Start the conversation!",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                // build message list
                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: message.length,
                  itemBuilder: (context, index) {
                    final msg = message[index];
                    final isMe =
                        msg.senderId == FirebaseAuth.instance.currentUser!.uid;
                    final isSystem = msg.type == 'system';
                    final isVideo = msg.callType == 'video';
                    final isMissed = msg.callStatus == 'missed';
                    final showDateHeader = shouldShowDateHeader(message, index);
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ///show the date on message header
                        if (showDateHeader)
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              children: [
                                Expanded(child: Divider()),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    formatDateHeader(msg.timestamp),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                          ),
                        if (isSystem)
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            margin: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            child: Text(
                              msg.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        ///display the audio and video call history
                        else if (msg.type == "call")
                          CallHistory(
                            isMe: isMe,
                            widget: widget,
                            isMissed: isMissed,
                            isVideo: isVideo,
                            message: msg,
                          )
                        /// display the text message and image
                        else
                          MessageAndImageDisplay(
                            isMe: isMe,
                            widget: widget,
                            message: msg,
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          /// message input
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 4,
                  color: Colors.grey.withAlpha(100),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _isUploading ? null : () => _showImageOptions(),
                  icon: Icon(Icons.image),
                ),
                Expanded(
                  child: TextField(
                    focusNode: _textFieldFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],

                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    onSubmitted: (value) => sendMessage(),
                    controller: _messageController,
                    onChanged: _handleTextChange,
                    onTap: _handleTextFieldFocus,
                  ),
                ),
                IconButton(
                  onPressed: _isUploading ? null : sendMessage,
                  icon: _isUploading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.send, color: Colors.blueAccent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Image handling methods
  //this methods is for image picker
  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  imageOptionItem(
                    icon: Icons.camera_alt,
                    label: "Camera",
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  imageOptionItem(
                    icon: Icons.photo_library,
                    label: "Gallery",
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);

        ///image preview
        await _showImagePreview(imageFile);
      }
    } catch (e) {
      if (mounted) {
        showAppSnackbar(
          context: context,
          type: SnackbarType.error,
          description: "Error picking image: $e",
        );
      }
    }
  }

  // preview image before sending
  Future<void> _showImagePreview(File imageFile) async {
    final result = await Navigator.push<ImagePreviewResult>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ImagePreviewScreen(imageFile: imageFile),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      await _sendImageMessage(result.imageFile, result.caption);
    }
  }

  // send image to firestore/storage
  Future<void> _sendImageMessage(File imageFile, String caption) async {
    setState(() {
      _isUploading = true;
    });
    try {
      final chatServices = ref.read(chatServiceProvider);
      final result = await chatServices.sendImageWithUpload(
        chatId: widget.chatId,
        imageFile: imageFile,
        caption: caption.isEmpty ? null : caption,
      );
      if (result == 'success') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              0.0,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        if (mounted) {
          showAppSnackbar(
            context: context,
            type: SnackbarType.error,
            description: "Error sending image: $result",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showAppSnackbar(
          context: context,
          type: SnackbarType.error,
          description: "Error sending image: $e",
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
}

Widget imageOptionItem({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: color.withAlpha(128),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}

class ImagePreviewResult {
  final File imageFile;
  final String caption;

  ImagePreviewResult({required this.imageFile, required this.caption});
}
