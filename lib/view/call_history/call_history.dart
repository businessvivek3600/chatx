import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/utils/time_format.dart';
import '../../model/message_model.dart';
import '../../providers/provider.dart';
import '../chats/widgets/audio_video_call_button.dart';

class CallHistoryScreen extends ConsumerStatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  ConsumerState<CallHistoryScreen> createState() =>
      _CallHistoryScreenState();
}

class _CallHistoryScreenState
    extends ConsumerState<CallHistoryScreen> {
  List<MessageModel> _cachedCalls = [];

  String _safeInitial(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    return name.trim()[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final chatServices = ref.watch(chatServiceProvider);
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Calls history',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<List<MessageModel>>(
        stream: chatServices.getCallHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _cachedCalls.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.isNotEmpty) {
            _cachedCalls = snapshot.data!;
          }

          if (_cachedCalls.isEmpty) {
            return const _EmptyCallsView();
          }

          final calls = _cachedCalls.reversed.toList();

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            cacheExtent: 600,
            itemCount: calls.length,
            separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final call = calls[index];
              final bool isVideo = call.callType == 'video';
              final bool isMissedIncoming =
                  call.callStatus == 'missed' &&
                      call.senderId != currentUserId;

              final Color callColor =
              isMissedIncoming ? Colors.red : Colors.grey.shade700;

              final String otherUserId =
              call.senderId == currentUserId
                  ? call.receiverId!
                  : call.senderId;

              final String otherUserName =
              call.senderId == currentUserId
                  ? (call.receiverName ?? '')
                  : call.senderName;

              return ListTile(
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.blueGrey.shade200,
                  child: Text(
                    _safeInitial(otherUserName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  otherUserName.isNotEmpty
                      ? otherUserName
                      : 'Unknown',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color:
                    isMissedIncoming ? Colors.red : Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isVideo ? Icons.videocam : Icons.call,
                          size: 16,
                          color: callColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isMissedIncoming
                              ? 'Missed ${isVideo ? "video" : "voice"} call'
                              : isVideo
                              ? 'Video call'
                              : 'Voice call',
                          style: TextStyle(
                            color: callColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      call.timestamp != null
                          ? formatTime(call.timestamp!)
                          : '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                trailing: actionButton(
                  isVideo,
                  otherUserId,
                  otherUserName,
                  ref,
                  call.chatId!,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyCallsView extends StatelessWidget {
  const _EmptyCallsView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.call_outlined, size: 72, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No calls yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}