import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatx/model/contact_list_model.dart';
import 'package:chatx/model/user_model.dart';
import 'package:chatx/providers/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class ContactListNotifier extends StateNotifier<ContactListModel> {
  final Ref ref;
  final UserModel user;
  ContactListNotifier(this.ref, this.user)
      : super(
    ContactListModel(
      isLoading: false,
      areFriends: false,
      isRequestSender: false,
      requestStatus: null,
      pendingRequestId: null,
    ),
  ) {
    _checkRelationship();
  }


  Future<void> _checkRelationship() async {
    final chatService = ref.read(chatServiceProvider);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final friends =
    await chatService.areUsersFriends(currentUserId, user.uid);

    if (friends) {
      state = state.copyWith(
        areFriends: true,
        requestStatus: null,
        isRequestSender: false,
        pendingRequestId: null,
      );
      return;
    }

    final senderRequestId = '${currentUserId}_${user.uid}';
    final receiverRequestId = '${user.uid}_$currentUserId';

    final sendRequestDoc = await FirebaseFirestore.instance
        .collection('messageRequests')
        .doc(senderRequestId)
        .get();

    final receiveRequestDoc = await FirebaseFirestore.instance
        .collection('messageRequests')
        .doc(receiverRequestId)
        .get();

    String? finalStatus;
    bool isSender = false;
    String? requestId;

    /// CASE 1: current user sent request
    if (sendRequestDoc.exists) {
      final data = sendRequestDoc.data();
      final sentStatus = data?['status'];

      if (sentStatus == 'pending') {
        finalStatus = 'pending';
        isSender = true;
        requestId = senderRequestId;
      }
    }

    /// CASE 2: current user received request
    else if (receiveRequestDoc.exists) {
      final data = receiveRequestDoc.data();
      final receivedStatus = data?['status'];

      if (receivedStatus == 'pending') {
        finalStatus = 'pending';
        isSender = false;
        requestId = receiverRequestId;
      }
    }

    state = state.copyWith(
      areFriends: false,
      requestStatus: finalStatus,
      isRequestSender: isSender,
      pendingRequestId: requestId,
    );
  }


  Future<String> sendRequest() async {
    state = state.copyWith(isLoading: true);
    final chatService = ref.read(chatServiceProvider);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final result = await chatService.sendMessageRequest(
      receiverUid: user.uid,
      receiverName: user.name,
      receiverEmail: user.email,
    );
    if (result == 'success') {
      state = state.copyWith(
        isLoading: false,
        requestStatus: 'pending',
        isRequestSender: true,
        pendingRequestId: '${currentUserId}_${user.uid}',
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
    return result;
  }

  Future<String> acceptRequest() async {
    if (state.pendingRequestId == null) return 'No pending request';

    state = state.copyWith(isLoading: true);
    final chatService = ref.read(chatServiceProvider);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final result = await chatService.acceptMessageRequest(
      state.pendingRequestId!,
      user.uid,
    );
    if (result == 'success') {
      state = state.copyWith(
        isLoading: false,
        areFriends: true,
        requestStatus: null,
        isRequestSender: false,
        pendingRequestId: null,
      );
      //refresh providers
      ref.invalidate(requestProvider);
      ref.invalidate(chatsProvider);
    } else {
      state = state.copyWith(isLoading: false);
      return result;
    }
    return result;
  }
}

final userListProvider =
    StateNotifierProvider.family<
      ContactListNotifier,
      ContactListModel,
      UserModel
    >((ref, user) => ContactListNotifier(ref, user));
