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
      body:StreamBuilder<List<MessageModel>>(
        stream: chatServices.getCallHistory(),
        builder: (context, snapshot) {
          // 1. Still loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error
          if (snapshot.hasError) {
            debugPrint("Call history error: ${snapshot.error}");
            return Center(child: Text("Something went wrong"));
          }

          // 3. Data received (even if empty)
          final calls = snapshot.data ?? [];

          // 🔍 DEBUG PRINT
          debugPrint("Call history count: ${calls.length}");
          for (var call in calls) {
            debugPrint(
              "CALL → ${call.senderName}, "
                  "type=${call.callType}, "
                  "status=${call.callStatus}, "
                  "time=${call.timestamp}",
            );
          }

          // 4. No calls
          if (calls.isEmpty) {
            return const Center(child: Text("No calls yet"));
          }

          // 5. Show list
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
