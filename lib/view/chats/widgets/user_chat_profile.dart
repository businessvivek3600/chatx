import 'package:chatx/providers/provider.dart';
import 'package:chatx/view/chats/chat_screen.dart';
import 'package:chatx/view/chats/widgets/dot_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/colors.dart';
import '../../../providers/user_state_provider.dart';

class UserChatProfile extends StatelessWidget {
  const UserChatProfile({super.key, required this.widget});
  final ChatScreen widget;
  @override
  Widget build(BuildContext context) {
    final user = widget.otherUser;
    return Consumer(
      builder: (context, ref, _) {
        final statusAsync = ref.watch(userStateProvider(user.uid));
        final typingStatus = ref.watch(typingProvider(widget.chatId));
        final  isOtherUserTyping = typingStatus[user.uid] ?? false;
        return statusAsync.when(
          data: (isOnline) => Row(
            children: [
              CircleAvatar(
                backgroundColor: kPrimary,
                backgroundImage: user.photoUrl != null
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: user.photoUrl == null
                    ? Text(
                        user.name[0],
                        style: TextStyle(color: Colors.white70),
                      )
                    : null,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      ),
                    ),
                    SizedBox(height: 6),
                   if(isOtherUserTyping)
                     Row(
                       children: [
                         Text("Typing",style: TextStyle(color: Colors.grey.shade600,fontSize: 10),),
                         SizedBox(width: 4,),
                         ThreeDots(),
                       ],
                     )else if(isOnline)
                     Text("Online",style: TextStyle(color: Colors.green,fontSize: 10),)
                    else
                     Text("Offline",style: TextStyle(color: Colors.grey.shade600,fontSize: 10),)
                  ],
                ),
              ),
            ],
          ),
          error: (_, _) => Text(user.name),
          loading: () => Text(user.name),
        );
      },
    );
  }
}
