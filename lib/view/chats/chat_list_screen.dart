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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //force refresh when screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(requestProvider);
      ref.invalidate(chatsProvider);
      onRefresh();
    });
  }

  Future<void> onRefresh() async {
    // clear friendship cache before refreshing
    ref.invalidate(chatsProvider);
    ref.invalidate(requestProvider);
    //wait a bit for the data to be refreshed
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final pendingRequests = ref.watch(requestProvider);
    final chats = ref.watch(chatsProvider);
    //count pending request
    final requestCount = pendingRequests.when(
      data: (data) => data.length,
      error: (error, stackTrace) => 0,
      loading: () => 0,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Chats',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        actions: [
          ///Notification icon only when there are pending requests
          IconButton(
            onPressed: () => NavigationHelper.push(context, RequestScreen()),
            icon: Stack(
              children: [
                Icon(Icons.notifications, color: Colors.black),
                if (requestCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$requestCount',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      // pull-to-refresh + chat list display
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: chats.when(
          /// case 1: chats loaded successfully
          data: (chatsLists) {
            if (chatsLists.isEmpty) {
              return ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 200),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'No chats yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Go  to users tab to send a message requests',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            /// --- if chats exists -> show chat list ---
            return ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: chatsLists.length,
              itemBuilder: (context, index) {
                final chat = chatsLists[index];
                //fetch other user details
                return FutureBuilder<UserModel?>(
                  future: _getOtherUser(chat.participants),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return SizedBox();
                    final otherUsers = snapshot.data!;
                    final currentUserId =
                        FirebaseAuth.instance.currentUser?.uid;
                    if (currentUserId == null) return SizedBox();
                    // count unread messages
                    // Get unread count for current user - CORRECT LOGIC
                    final unReadCount = chat.unreadCount[currentUserId] ?? 0;

// Show unread highlight if:
// 1. There are unread messages (unReadCount > 0)
// 2. The last message was NOT sent by current user
                    final shouldShowUnread = unReadCount > 0 && chat.lastSenderId != currentUserId;

                    return ListTile(
                      //user profile + online/offline status
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: kPrimary,
                            backgroundImage: otherUsers.photoUrl != null
                                ? NetworkImage(otherUsers.photoUrl!)
                                : null,
                            child: Text(
                              otherUsers.photoUrl == null
                                  ? otherUsers.name[0]
                                  : "U",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),

                          ///online/offline status
                          if (chat.participants.contains(currentUserId))
                            Positioned(
                              bottom: 0,
                              right: 2,
                              child: Consumer(
                                builder: (context, ref, _) {
                                  final statusAsync = ref.watch(
                                    userStateProvider(otherUsers.uid),
                                  );

                                  return statusAsync.when(
                                    data: (isOnline) => CircleAvatar(
                                      radius: 5,
                                      backgroundColor: isOnline
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                    error: (error, _) => Text(otherUsers.email),
                                    loading: () => Text(otherUsers.email),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),

                      ///name of the user
                      title: Text(
                        otherUsers.name,
                        style: TextStyle(
                          fontWeight: shouldShowUnread
                              ? FontWeight.bold
                              : FontWeight.normal,

                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        chat.lastMessage.isNotEmpty
                            ? chat.lastMessage
                            : "You can now start to chat",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: shouldShowUnread ? FontWeight.bold : FontWeight.normal,

                          color: Colors.black,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(formatTime(chat.lastMessageTime),style: TextStyle(
                            fontSize: 12,
                            color: shouldShowUnread ? Colors.blue : Colors.grey,
                          ),),
                          if (shouldShowUnread && unReadCount > 0)
                            Container(
                              margin: EdgeInsets.only(top: 4),
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: Text(  unReadCount > 9 ? '9+' : '$unReadCount',style: TextStyle(color: Colors.white,fontSize: 12),),
                            )
                        ],
                      ),
                      onTap: () => NavigationHelper.push(
                        context,
                        ChatScreen(chatId: chat.chatId, otherUser: otherUsers),
                      ),
                    );
                  },
                );
              },
            );
          },

          /// Case 3: case on error state
          error: (error, _) => ListView(
            children: [
              SizedBox(height: 200),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.error_outline, size: 100, color: Colors.red),
                    SizedBox(height: 20),
                    Text(
                      'Error loading chats',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Please try again later',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: onRefresh,
                      child: Text('Refresh'),
                    ),
                  ],
                ),
              ),
            ],
          ),

          /// Case 2: case to loading state
          loading: () => Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  // helper method -. get details of the other user in chat
  Future<UserModel?> _getOtherUser(List<String> participants) async {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid == null) return null;
    final otherUserUid = participants.firstWhere(
      (uid) => uid != currentUserUid,
    );
    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(otherUserUid)
          .get();
      return doc.exists ? UserModel.fromMap(doc.data()!) : null;
    } catch (e) {
      print("Error getting other user: $e");
      return null;
    }
  }
}
