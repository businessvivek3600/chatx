import 'package:chatx/core/utils/app_utils.dart';
import 'package:chatx/model/contact_list_model.dart';
import 'package:chatx/model/user_model.dart';
import 'package:chatx/providers/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/contact_list_provider.dart';
import '../../providers/user_state_provider.dart';
import '../../view/chats/chat_screen.dart';
import '../utils/chat_id.dart';
import '../utils/colors.dart';
import 'card_decoration.dart';

class UserListTile extends ConsumerWidget {
  final UserModel user;
  const UserListTile({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(userListProvider(user).notifier);
    final state = ref.watch(userListProvider(user));
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: AppDecorations.card3D(),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kPrimary,
          backgroundImage: user.photoUrl != null
              ? NetworkImage(user.photoUrl!)
              : null,
          child: user.photoUrl == null
              ? Text(user.name[0], style: TextStyle(color: Colors.white70))
              : null,
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        // show online /offline status in subtitle
        subtitle: Consumer(
          builder: (context, ref, child) {
            final statusAsync = ref.watch(userStateProvider(user.uid));
            return statusAsync.when(
              data: (status) => Text(
                status ? 'Online' : 'Offline',
                style: TextStyle(color: status ? Colors.green : Colors.grey),
              ),
              error: (_, __) => Text(user.email),
              loading: () => Text(user.email),
            );
          },
        ),
        //we will make it functional some time later
        // right - side action button (chat,add friend,accept request,etc )
        trailing: _buildTrailingWidget(context, ref, notifier, state),
      ),
    );
  }

  Widget _buildTrailingWidget(
    BuildContext context,
    WidgetRef ref,
    ContactListNotifier notifier,
    ContactListModel state,
  ) {
    if (state.isLoading) {
      ///show loading spinner while checking status
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    /// already friends -> show 'chat' button
    if (state.areFriends) {
      return MaterialButton(
        color: Colors.green,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide.none,
        ),
        onPressed: () {
          _navigateToChatScreen(context);
        },
        child: buttonName(Icons.chat, 'Chat'),
      );
    }

    ///Current user sent the request -> show "pending"
    if (state.requestStatus == 'pending') {
      if (state.isRequestSender) {
        return ElevatedButton(
          onPressed: null,
          child: SizedBox(
            height: 32,
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pending_actions, color: Colors.black, size: 20),
                const SizedBox(width: 5),
                Text(
                  'Pending',
                  style: TextStyle(
                    fontSize: 1,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        //current user received the request -> show "accept" buttons
        return MaterialButton(
          color: Colors.orange,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide.none,
          ),
          onPressed: () async {
            debugPrint('ACCEPT BUTTON CLICKED');
            debugPrint('User ID: ${user.uid}');

            try {
              final result = await notifier.acceptRequest();

              debugPrint('Accept Request Result: $result');

              if (result == 'success' && context.mounted) {
                debugPrint('✅ Request accepted successfully');
                showAppSnackbar(
                  context: context,
                  type: SnackbarType.success,
                  description: 'Request Accepted!',
                );
              } else if (context.mounted) {
                debugPrint('❌ Accept request failed: $result');
                showAppSnackbar(
                  context: context,
                  type: SnackbarType.error,
                  description: "Failed: $result",
                );
              }
            } catch (e, stack) {
              debugPrint('🔥 Exception while accepting request');
              debugPrint('Error: $e');
              debugPrint('StackTrace: $stack');
            }
          },

          child: buttonName(Icons.done, "Accept"),
        );
      }
    }
    // default -> not friends ter-> show "add friend" button
    return MaterialButton(
      color: Colors.blueAccent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(10),
      ),
      onPressed: () async {
        debugPrint('ADD FRIEND BUTTON CLICKED');
        debugPrint('Target User ID: ${user.uid}');

        try {
          final result = await notifier.sendRequest();

          debugPrint('Send Request Result: $result');

          if (result == 'success' && context.mounted) {
            debugPrint('✅ Friend request sent successfully');
            showAppSnackbar(
              context: context,
              type: SnackbarType.success,
              description: 'Request sent successfully',
            );
          } else if (context.mounted) {
            debugPrint('❌ Send request failed: $result');
            showAppSnackbar(
              context: context,
              type: SnackbarType.error,
              description: "Failed: $result",
            );
          }
        } catch (e, stack) {
          debugPrint('🔥 Exception while sending request');
          debugPrint('Error: $e');
          debugPrint('StackTrace: $stack');
        }
      },

      child: buttonName(Icons.person_add, 'Add Friend'),
    );
  }

  SizedBox buttonName(IconData icon, String name) {
    return SizedBox(
      width: 110,
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 5),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  //Navigator to chat Screen when "chat button clicked
  Future<void> _navigateToChatScreen(BuildContext context) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final chatId = generateChatId(currentUserId!, user.uid);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatId: chatId, otherUser: user),
      ),
    );
  }
}
