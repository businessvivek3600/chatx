import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:chatx/model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatx/model/message_request_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../core/utils/chat_id.dart';
import '../model/chat_model.dart';
import '../model/user_model.dart';

class ChatServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserUid => _auth.currentUser!.uid;

  ///----------------------USERS----------------
  /// Retrieves a stream of all users except the currently logged-in user
  Stream<List<UserModel>> getAllUsers() {
    try {
      final String uid = _auth.currentUser?.uid ?? '';
      if (uid.isEmpty) {
        return Stream.value([]);
      }
      return _firestore
          .collection('users')
          .where("uid", isNotEqualTo: uid)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return UserModel.fromMap(doc.data());
            }).toList();
          });
    } catch (e) {
      debugPrint("Error fetching users: $e");
      return Stream.value([]);
    }
  }

  ///---------------------- Online status----------
  Future<void> updateUserOnlineStatus(bool isOnline) async {
    if (currentUserUid.isEmpty) return;
    try {
      await _firestore.collection('users').doc(currentUserUid).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error updating user online status: $e");
    }
  }

  ///---------------------- Are User Friends----------
  Future<bool> areUsersFriends(String uid1, String uid2) async {
    final chatId = generateChatId(uid1, uid2);

    final friendship = await _firestore
        .collection('friendships')
        .doc(chatId)
        .get();
    final exists = friendship.exists;
    return exists;
  }

  ///---------------------- UNFRIEND----------
  Future<String> unfriendUser(String chatID, String friendId) async {
    try {
      final batch = _firestore.batch();

      ///delete friendship
      batch.delete(_firestore.collection('friendships').doc(chatID));

      ///delete chat
      batch.delete(_firestore.collection('chats').doc(chatID));

      ///delete all messages in chat
      final messages = await _firestore
          .collection('messages')
          .where('chatId', isEqualTo: chatID)
          .get();
      for (final doc in messages.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return 'success';
    } catch (e) {
      debugPrint("Error unfriending user: $e");
      return e.toString();
    }
  }

  /// Now we have required a
  /// 1. send message request
  /// 2. accept message request

  ///---------------------Message request -----------------------
  Future<String> sendMessageRequest({
    required String receiverUid,
    required String receiverName,
    required String receiverEmail,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      final requestId = '${currentUserUid}_$receiverUid';

      /// get photo url from firestore user collection
      final user = await _firestore
          .collection('users')
          .doc(currentUserUid)
          .get();
      String? receiverPhotoUrl;
      if (user.exists) {
        final userData = UserModel.fromMap(user.data()!);
        receiverPhotoUrl = userData.photoUrl;
      }
      final existingRequest = await _firestore
          .collection('messageRequests')
          .doc(requestId)
          .get();
      if (existingRequest.exists &&
          existingRequest.data()?['status'] == 'pending') {
        return 'Request already sent';
      }
      final request = MessageRequestModel(
        id: requestId,
        senderUid: currentUserUid,
        receiverUid: receiverUid,
        senderName: currentUser?.displayName ?? 'user',
        senderEmail: currentUser?.email ?? '',
        status: 'pending',
        createdAt: DateTime.now(),
        photoUrl: receiverPhotoUrl,
      );
      await _firestore
          .collection('messageRequests')
          .doc(requestId)
          .set(request.toMap());

      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<MessageRequestModel>> getPendingRequest() {
    if (currentUserUid.isEmpty) return Stream.value([]);
    return _firestore
        .collection('messageRequests')
        .where('receiverUid', isEqualTo: currentUserUid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageRequestModel.fromMap(doc.data()))
              .toList(),
        );
  }

  ///Accept message request
  Future<String> acceptMessageRequest(String requestId, String senderId) async {
    try {
      final batch = _firestore.batch();
      // update request status
      batch.update(_firestore.collection('messageRequests').doc(requestId), {
        'status': 'accepted',
      });
      // create friendship
      final friendshipId = generateChatId(currentUserUid, senderId);
      batch.set(_firestore.collection('friendships').doc(friendshipId), {
        'participants': [currentUserUid, senderId],
        'createdAt': FieldValue.serverTimestamp(),
      });

      //create chat with proper unread count initialization
      batch.set(_firestore.collection('chats').doc(friendshipId), {
        'chatId': friendshipId,
        'participants': [currentUserUid, senderId],
        'lastMessage': '',
        'lastSenderId': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': {currentUserUid: 0, senderId: 0}, // Initialize both to 0
      });

      //system message
      //auto generate message when request is accepted
      final messageId = _firestore.collection('messages').doc().id;
      batch.set(_firestore.collection('messages').doc(messageId), {
        'messageId': messageId,
        'chatId': friendshipId,
        'senderId': 'system',
        'senderName': 'System',
        'message': 'Request has been accepted. You can now start chatting.',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'system',
        'readBy': {
          currentUserUid: FieldValue.serverTimestamp(),
          senderId: FieldValue.serverTimestamp(),
        },
      });

      await batch.commit();
      debugPrint('Message request accepted');
      return 'success';
    } catch (e) {
      debugPrint('Error accepting message request: $e');
      return e.toString();
    }
  }

  ///Reject message request
  Future<String> rejectMessageRequest(
    String requestId, {
    bool deleteRequest = true,
  }) async {
    try {
      if (deleteRequest) {
        await _firestore.collection('messageRequests').doc(requestId).delete();
      } else {
        await _firestore.collection('messageRequests').doc(requestId).update({
          'status': 'rejected',
        });
      }
      debugPrint('Message request rejected');
      return 'success';
    } catch (e) {
      debugPrint('Error rejecting message request: $e');
      return e.toString();
    }
  }

  ///----------------------CHAT-----------------
  // add caching for chats
  final Map<String, ChatModel> _chatCache = {};

  Stream<List<ChatModel>> getUserChats() {
    if (currentUserUid.isEmpty) return Stream.value([]);
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserUid)
        //if you have user orderBy and where on sam e collection then you need
        .orderBy('lastMessageTime', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .map((doc) => ChatModel.fromMap(doc.data()))
              .toList();
          return docs;
        });
  }

  Stream<List<MessageModel>> getChatMessages(
    String chatId, {
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) {
    Query query = _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .limit(limit);
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    return query.snapshots().map((snapshot) {
      final docs = snapshot.docs
          .map(
            (doc) => MessageModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
      return docs;
    });
  }

  ///Send chat message - FIXED UNREAD COUNT
  Future<String> sendMessage({
    required String chatId,
    required String message,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      final messageId = _firestore.collection('messages').doc().id;
      final batch = _firestore.batch();

      // Create message
      batch.set(_firestore.collection('messages').doc(messageId), {
        'messageId': messageId,
        'chatId': chatId,
        'senderId': currentUserUid,
        'senderName': currentUser?.displayName ?? 'user',
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'readBy': {
          currentUserUid:
              FieldValue.serverTimestamp(), // Mark as read by sender
        },
        'type': 'user',
      });

      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) {
        return "Chat not found";
      }
      final chatData = chatDoc.data()!;
      final participants = List<String>.from(chatData['participants']);
      final otherUserId = participants.firstWhere((id) => id != currentUserUid);

      // Get current unread counts
      final currentUnreadCounts = Map<String, int>.from(
        chatData['unreadCount'] ?? {},
      );

      // Update chat - FIXED UNREAD COUNT LOGIC
      batch.update(_firestore.collection('chats').doc(chatId), {
        'lastMessage': message,
        'lastSenderId': currentUserUid,
        'lastMessageTime': FieldValue.serverTimestamp(),
        // Increment for receiver, reset for sender
        'unreadCount.$otherUserId': (currentUnreadCounts[otherUserId] ?? 0) + 1,
        'unreadCount.$currentUserUid': 0, // Reset for current user
      });

      await batch.commit();
      return 'success';
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }

  ///--------------------------------IMAGE MESSAGES ---------------------
  Future<String> uploadImage(File imageFile, String chatId) async {
    try {
      final filename =
          '${DateTime.now().millisecondsSinceEpoch}_$currentUserUid.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child(chatId)
          .child(filename);
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }

  /// send image Message - FIXED UNREAD COUNT
  Future<String> sendImageMessage({
    required String chatId,
    required String imageUrl,
    String? caption,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      final messageId = _firestore.collection('messages').doc().id;

      final batch = _firestore.batch();
      // create image message
      batch.set(_firestore.collection('messages').doc(messageId), {
        'messageId': messageId,
        'senderId': currentUserUid,
        'senderName': currentUser?.displayName ?? 'user',
        'message': caption ?? '',
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'readBy': {
          currentUserUid:
              FieldValue.serverTimestamp(), // Mark as read by sender
        },
        'chatId': chatId,
        'type': 'image',
      });

      //update chat message with last message
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) {
        return "Chat not found";
      }
      final chatData = chatDoc.data()!;
      final participants = List<String>.from(chatData['participants']);
      final otherUserId = participants.firstWhere((id) => id != currentUserUid);

      // Get current unread counts
      final currentUnreadCounts = Map<String, int>.from(
        chatData['unreadCount'] ?? {},
      );

      batch.update(_firestore.collection('chats').doc(chatId), {
        'lastMessage': caption?.isNotEmpty == true ? caption : '📸 Photo',
        'lastSenderId': currentUserUid,
        'lastMessageTime': FieldValue.serverTimestamp(),
        // Increment for receiver, reset for sender
        'unreadCount.$otherUserId': (currentUnreadCounts[otherUserId] ?? 0) + 1,
        'unreadCount.$currentUserUid': 0, // Reset for current user
      });

      await batch.commit();
      return 'success';
    } catch (e) {
      debugPrint("Error sending image message: $e");
      return e.toString();
    }
  }

  Future<String> sendImageWithUpload({
    required String chatId,
    required File imageFile,
    String? caption,
  }) async {
    try {
      /// upload image first
      final imageUrl = await uploadImage(imageFile, chatId);
      if (imageUrl.isEmpty) {
        return "Error uploading image";
      }

      /// send image message
      return await sendImageMessage(
        chatId: chatId,
        imageUrl: imageUrl,
        caption: caption,
      );
    } catch (e) {
      debugPrint("Error sending image message: $e");
      return e.toString();
    }
  }

  ///---------------------CALL HISTORY----------------------
 Future<String> addCallHistory({
  required String chatId,
  
  required bool isVideoCall,
  required String callStatus, // 'missed', 'outgoing', 'answered'
  int? duration,
}) async {
  try {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return 'User not logged in';

    final messageId = _firestore.collection('messages').doc().id;

    await _firestore.collection('messages').doc(messageId).set({
      'messageId': messageId,

      // 🔑 WHO initiated the call
      'senderId': currentUser.uid,
      'senderName': currentUser.displayName ?? 'user',

      // 📞 Call info
      'message': isVideoCall ? 'Video call' : 'Audio call',
      'callType': isVideoCall ? 'video' : 'audio',
      'callStatus': callStatus, // missed / outgoing / answered
      'duration': duration ?? 0,

      // ⏱ Time
      'timestamp': FieldValue.serverTimestamp(),

      // 📌 Meta
      'chatId': chatId,
      'type': 'call',

      // 👁 Read status
      'readBy': {
        currentUser.uid: FieldValue.serverTimestamp(),
      },
    });

    return 'success';
  } catch (e) {
    debugPrint("Error adding call history: $e");
    return e.toString();
  }
}


  ///---------------------- Mark Message As Read (message status) -------------------
  Future<void> markMessageAsRead(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      // 1. Reset unread count (this NEVER needs an index)
      await _firestore.collection('chats').doc(chatId).update({
        'unReadCount.${currentUser.uid}': 0,
      });

      // 2. Get all messages in chat (simple query)
      final messagesQuery = await _firestore
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .get();

      final batch = _firestore.batch();

      for (var doc in messagesQuery.docs) {
        final data = doc.data();

        // Skip my own messages
        if (data['senderId'] == currentUser.uid) continue;

        final readBy = Map<String, dynamic>.from(data['readBy'] ?? {});

        if (!readBy.containsKey(currentUser.uid)) {
          batch.update(doc.reference, {
            'readBy.${currentUser.uid}': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
    } catch (e) {
      debugPrint("Error marking as read: $e");
    }
  }

  /// Get unread messages count for current user
  Future<int> getUnreadCount(String chatId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return 0;

      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) return 0;

      final chatData = chatDoc.data()!;
      final unreadCounts = Map<String, int>.from(chatData['unreadCount'] ?? {});

      return unreadCounts[currentUserId] ?? 0;
    } catch (e) {
      debugPrint("Error getting unread count: $e");
      return 0;
    }
  }

  ///-------------------------------- Typing Indicator ---------------------
  Stream<Map<String, bool>> getTypingStatus(String chatId) {
    return _firestore.collection("chats").doc(chatId).snapshots().map((doc) {
      if (!doc.exists) return <String, bool>{};
      final data = doc.data() as Map<String, dynamic>;
      final typing = data['typing'] as Map<String, dynamic>? ?? {};
      final typingTimeStamp =
          data['typingTimeStamp'] as Map<String, dynamic>? ?? {};
      final result = <String, bool>{};
      final now = DateTime.now();
      typing.forEach((userId, isTyping) {
        if (userId != currentUserUid) {
          // check if typing status is recent (within 5 second)

          final timeStamp = typingTimeStamp[userId];
          if (timeStamp != null && isTyping == true) {
            final typingTime = (timeStamp as Timestamp).toDate();
            final isRecent = now.difference(typingTime).inSeconds < 5;
            result[userId] = isRecent;
          } else {
            result[userId] = false;
          }
        }
      });
      return result;
    });
  }

  Future<void> setTypingStatus(String chatId, bool isTyping) async {
    if (currentUserUid.isEmpty) return;
    try {
      await _firestore.collection("chats").doc(chatId).update({
        'typing.$currentUserUid': isTyping,
        'typingTimeStamp.$currentUserUid': FieldValue.serverTimestamp(),
      });
      //only set cleanup timer when stopping typing
      if (!isTyping) {
        Future.delayed(Duration(seconds: 1), () async {
          try {
            await _firestore.collection("chats").doc(chatId).update({
              'typing.$currentUserUid': false,
              'typingTimeStamp.$currentUserUid': FieldValue.serverTimestamp(),
            });
          } catch (e) {
            debugPrint("Error setting typing status: $e");
          }
        });
      }
    } catch (e) {
      debugPrint("Error setting typing status: $e");
    }
  }
  ///_________________________CALL HISTORY--------------------
Stream<List<MessageModel>> getCallHistory() {
  return _firestore
      .collection('messages')
      .where('type', isEqualTo: 'call')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((d) => MessageModel.fromMap(d.data()))
            .toList(),
      );
}


Future<void> deleteMessage({
  required String chatId,
  required String messageId,
}) async {
  try {
    await FirebaseFirestore.instance
        .collection('messages')
        .doc(messageId)
        .delete();

    debugPrint("✅ Message deleted: $messageId");
  } catch (e) {
    debugPrint("❌ Error deleting message: $e");
    rethrow;
  }
}

 Future<void> updateMessageReaction({
  required String chatId,
  required String messageId,
  required String? reaction,
}) async {
  try {
    final docRef =
        _firestore.collection('messages').doc(messageId);

    if (reaction == null) {
      // ❌ REMOVE reaction
      await docRef.update({
        'reaction': FieldValue.delete(),
      });
    } else {
      // ✅ ADD / UPDATE reaction
      await docRef.update({
        'reaction': reaction,
      });
    }

    debugPrint("✅ Reaction updated: $reaction");
  } catch (e) {
    debugPrint("❌ Error updating reaction: $e");
  }
}

  Future<void> deleteChat(String chatId) async {}






}
