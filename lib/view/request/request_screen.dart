import 'package:chatx/core/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/provider.dart';

class RequestScreen extends ConsumerStatefulWidget {
  const RequestScreen({super.key});

  @override
  ConsumerState<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends ConsumerState<RequestScreen> {
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(requestProvider);
    });
    super.initState();
  }
  bool _isValidNetworkImage(String? url) {
    if (url == null || url.isEmpty) return false;

    final uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(requestProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Message Requests'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(requestProvider),
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: requests.when(
        data: (requestList) {
          if (requestList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  Text(
                    'No pending requests',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          /// if requests exists -> show list of requests
          return ListView.builder(
            itemCount: requestList.length,
            itemBuilder: (context, index) {
              final request = requestList[index];
              return Card(
                elevation: 0,
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: _isValidNetworkImage(request.photoUrl)
                        ? NetworkImage(request.photoUrl!)
                        : null,
                    child: _isValidNetworkImage(request.photoUrl)
                        ? null
                        : const Icon(Icons.person, size: 30),
                  ),

                  title: Text(request.senderName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ///accept Request
                      GestureDetector(
                        onTap: () async {
                          await ref
                              .read(requestProvider.notifier)
                              .acceptRequest(request.id, request.senderUid);
                          if (context.mounted) {
                            showAppSnackbar(
                              context: context,
                              type: SnackbarType.success,
                              description: "Request accepted!",
                            );
                            //Refresh all Provider
                            ref.invalidate(contactProvider);
                            ref.invalidate(requestProvider);
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.done, color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 10),
                      ///Reject request
                      GestureDetector(
                        onTap: () async {
                          await ref
                              .read(requestProvider.notifier)
                              .rejectRequest(request.id);
                          if (context.mounted) {
                            showAppSnackbar(
                              context: context,
                              type: SnackbarType.success,
                              description: "Request rejected!",
                            );
                            //Refresh all Provider
                            ref.invalidate(contactProvider);
                            ref.invalidate(requestProvider);
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(request.senderEmail),
                ),
              );
            },
          );
        },

        /// case 2 error state
        error: (error, _) => Center(
          child: Column(
            children: [
              Text("Error:$error"),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(requestProvider),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
        loading: () => Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
