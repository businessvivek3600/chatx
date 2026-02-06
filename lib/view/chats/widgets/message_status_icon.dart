import 'package:chatx/model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


Widget buildMessageStatusIcon(
  MessageModel message,
  String receiverUid,
) {
  final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

  
  if (message.senderId != currentUserUid) {
    return const SizedBox.shrink();
  }

  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('users')
        .doc(receiverUid)
        .snapshots(),
    builder: (context, snapshot) {
      bool isReceiverOnline = false;

      if (snapshot.hasData && snapshot.data!.exists) {
        final data = snapshot.data!.data() as Map<String, dynamic>;
        isReceiverOnline = data['isOnline'] == true;
      }

 
      final bool isSeen =
          message.readBy != null &&
          message.readBy!.containsKey(receiverUid);

      if (isSeen) {
        return const Icon(
          Icons.done_all,
          size: 16,
          color: Colors.blue,
        );
      }

      
      if (isReceiverOnline) {
        return const Icon(
          Icons.done_all,
          size: 16,
          color: Colors.grey,
        );
      }

 
      return const Icon(
        Icons.done,
        size: 16,
        color: Colors.white,
      );
    },
  );
}
