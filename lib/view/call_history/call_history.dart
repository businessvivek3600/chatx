import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/time_format.dart';
import '../../model/message_model.dart';
import '../../providers/provider.dart';

class CallHistoryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatServices = ref.watch(chatServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Calls")),
      body: StreamBuilder<List<MessageModel>>(
        stream: chatServices.getCallHistory(),
        builder: (context, snapshot) {
          // if (!snapshot.hasData) {
          //   return Center(child: CircularProgressIndicator());
          // }

          final calls = snapshot.data ?? [];
          if (calls.isEmpty) {
            return Center(child: Text("No calls yet"));
          }

          return ListView.builder(
            itemCount: calls.length,
            itemBuilder: (context, index) {
              final call = calls[index];

              final isVideo = call.callType == 'video';
              final isMissed = call.callStatus == 'missed';

              return ListTile(
                leading: Icon(
                  isVideo ? Icons.videocam : Icons.call,
                  color: isMissed ? Colors.red : Colors.green,
                ),
                title: Text(call.senderName),
                subtitle: Text(
                  isMissed
                      ? "Missed ${isVideo ? "video" : "audio"} call"
                      : "Call duration: ${call.duration ?? 0}s",
                ),
                trailing: Text(formatTime(call.timestamp!)),
              );
            },
          );
        },
      ),
    );
  }
}
