import 'package:chatx/core/utils/navigation_helper.dart';
import 'package:chatx/model/user_model.dart';
import 'package:chatx/view/chats/chat_screen.dart';
import 'package:chatx/view/request/request_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/colors.dart';
import '../../core/utils/time_format.dart';
import '../../providers/provider.dart';
import '../../providers/user_state_provider.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(requestProvider);
      ref.invalidate(chatsProvider);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chats = ref.watch(chatsProvider);
    final requests = ref.watch(requestProvider);

    final requestCount = requests.maybeWhen(
      data: (d) => d.length,
      orElse: () => 0,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- HEADER ----------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Chats',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // 🔔 Notifications
                  IconButton(
                    onPressed: () =>
                        NavigationHelper.push(context, const RequestScreen()),
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications_none),
                        if (requestCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: CircleAvatar(
                              radius: 8,
                              backgroundColor: Colors.red,
                              child: Text(
                                '$requestCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ⋮ APP BAR MENU (KEPT)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) async {
                      if (value == 'logout') {
                        await FirebaseAuth.instance.signOut();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'settings', child: Text('Settings')),
                      PopupMenuItem(
                        value: 'logout',
                        child: Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ---------------- SEARCH ----------------
            Padding(
  padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
  child: Container(
    height: 44,
    decoration: BoxDecoration(
      color: const Color(0xFFF1F3F6),
      borderRadius: BorderRadius.circular(24),
    ),
    child: TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchText = value.toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: 'Search chats',
        hintStyle: const TextStyle(color: Colors.grey),
        border: InputBorder.none,
        prefixIcon: const Icon(
          Icons.search,
          color: Colors.grey,
        ),
        suffixIcon: _searchText.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: Colors.grey,
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchText = '';
                  });
                },
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
    ),
  ),
),


            const Divider(height: 1),

            // ---------------- CHAT LIST ----------------
            Expanded(
              child: chats.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    const Center(child: Text('Error loading chats')),
                data: (chatList) {
                  if (chatList.isEmpty) {
                    return const Center(child: Text('No chats yet'));
                  }

                  return ListView.separated(
                    itemCount: chatList.length,
                    separatorBuilder: (_, __) =>
                        const Divider(indent: 72, height: 1),
                    itemBuilder: (context, index) {
                      final chat = chatList[index];

                      return FutureBuilder<UserModel?>(
                        future: _getOtherUser(chat.participants),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(height: 72);
                          }

                          final otherUser = snapshot.data!;
                          final myId = FirebaseAuth.instance.currentUser!.uid;

                          if (_searchText.isNotEmpty &&
                              !otherUser.name.toLowerCase().contains(
                                _searchText,
                              )) {
                            return const SizedBox.shrink();
                          }

                          final unread = chat.unreadCount[myId] ?? 0;
                          final showUnread =
                              unread > 0 && chat.lastSenderId != myId;

                          return GestureDetector(
                            onLongPress: () =>
                                _showChatOptions(context, chat.chatId),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: _Avatar(user: otherUser),
                              title: Text(
                                otherUser.name,
                                style: TextStyle(
                                  fontWeight: showUnread
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                chat.lastMessage.isNotEmpty
                                    ? chat.lastMessage
                                    : 'Tap to start chatting',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatTime(chat.lastMessageTime),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: showUnread
                                          ? kPrimary
                                          : Colors.grey,
                                    ),
                                  ),
                                  if (showUnread)
                                    Container(
                                      margin: const EdgeInsets.only(top: 6),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: kPrimary,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Text(
                                        unread > 9 ? '9+' : unread.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () => NavigationHelper.push(
                                context,
                                ChatScreen(
                                  chatId: chat.chatId,
                                  otherUser: otherUser,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- iOS STYLE POPUP ----------------

  void _showChatOptions(BuildContext context, String chatId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _iosCard(
                  children: [
                    _iosTile(
                      Icons.person_outline,
                      'View profile',
                      () => Navigator.pop(context),
                    ),
                    _divider(),
                    _iosTile(
                      Icons.notifications_off_outlined,
                      'Mute',
                      () => Navigator.pop(context),
                    ),
                    _divider(),
                    _iosTile(Icons.delete_outline, 'Delete chat', () async {
                      Navigator.pop(context);
                      await ref.read(chatServiceProvider).deleteChat(chatId);
                    }, destructive: true),
                  ],
                ),
                const SizedBox(height: 8),
                _iosCancel(context),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------- HELPERS ----------------

  Future<UserModel?> _getOtherUser(List<String> participants) async {
    final myId = FirebaseAuth.instance.currentUser!.uid;
    final otherId = participants.firstWhere((id) => id != myId);

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(otherId)
        .get();

    return doc.exists ? UserModel.fromMap(doc.data()!) : null;
  }
}

// ---------------- iOS UI HELPERS ----------------

Widget _iosCard({required List<Widget> children}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(children: children),
  );
}

Widget _iosTile(
  IconData icon,
  String text,
  VoidCallback onTap, {
  bool destructive = false,
}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: destructive ? Colors.red : Colors.black),
          const SizedBox(width: 14),
          Text(
            text,
            style: TextStyle(
              fontSize: 17,
              color: destructive ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _iosCancel(BuildContext context) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Text(
          'Cancel',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
      ),
    ),
  );
}

Widget _divider() {
  return Container(
    height: 0.6,
    margin: const EdgeInsets.only(left: 52),
    color: Colors.grey.shade300,
  );
}

// ---------------- AVATAR ----------------

class _Avatar extends ConsumerWidget {
  final UserModel user;
  const _Avatar({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(userStateProvider(user.uid));

    return Stack(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundImage: user.photoUrl != null
              ? NetworkImage(user.photoUrl!)
              : null,
          child: user.photoUrl == null
              ? Text(
                  user.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        Positioned(
          bottom: 2,
          right: 2,
          child: status.maybeWhen(
            data: (online) => CircleAvatar(
              radius: 6,
              backgroundColor: online ? Colors.green : Colors.grey,
            ),
            orElse: () => const SizedBox(),
          ),
        ),
      ],
    );
  }
}
