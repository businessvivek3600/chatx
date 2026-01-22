import 'package:chatx/model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Builds the "message status" icon (✓, ✔✓,online check)

Widget buildMessageStatusIcon(MessageModel message, uid) {
  final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  // only show status for messages sent by current user
  if (message.senderId != currentUserUid) {
    return SizedBox();
  }
  // Listen to the receiver's (chat partner's ) user document
  return StreamBuilder(
    stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
    builder: (context, snapshot) {
      bool isReceiverOnline = false;
      //check if user document exists and fetch 'isOnline field'
      if (snapshot.hasData && snapshot.data!.exists) {
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        isReceiverOnline = userData['isOnline'] ?? false;
      }
      // check if the receiver has read this message
      final isMessageRead = message.readBy?.containsKey(uid) ?? false;
      if (isMessageRead) {
        // message was read by receiver then show two tick icon
        return Icon(Icons.done_all, color: Colors.white, size: 16);
      }else if(isReceiverOnline){
        // receiver is online but hasn't read then show two tick icon
        return Icon(Icons.done_all, color: Colors.black54, size: 16);
      }else{
        // receiver is offline then show one tick icon
        return Icon(Icons.check, color: Colors.black54, size: 16);
      }
    },
  );
}
