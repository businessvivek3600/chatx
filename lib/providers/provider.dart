import 'dart:async';
import 'dart:typed_data';

import 'package:chatx/model/message_request_model.dart';
import 'package:chatx/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/chat_model.dart';
import '../services/chat_services.dart';

///-------------------Auth State -------------------
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

///_________________________chat state----------------
final chatServiceProvider = Provider<ChatServices>((ref) {
  return ChatServices();
});

///--------------------------Contact List----------------
class ContactNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final ChatServices chatService;
  StreamSubscription<List<UserModel>>? _subscription;
  ContactNotifier(this.chatService) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _subscription?.cancel();
    _subscription = chatService.getAllUsers().listen(
      (users) => state = AsyncValue.data(users),
      onError: (error, stackTrace) =>
          state = AsyncValue.error(error, stackTrace),
    );
  }

  void refresh() => _init();
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final contactProvider =
    StateNotifierProvider<ContactNotifier, AsyncValue<List<UserModel>>>((ref) {
      final service = ref.watch(chatServiceProvider);
      return ContactNotifier(service);
    });

/// ---------------------------Request ------------------------
class RequestNotifier
    extends StateNotifier<AsyncValue<List<MessageRequestModel>>> {
  final ChatServices _chatServices;
  StreamSubscription<List<MessageRequestModel>>? _subscription;

  RequestNotifier(this._chatServices) : super(AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _subscription?.cancel();
    _subscription = _chatServices.getPendingRequest().listen(
      (request) => state = AsyncValue.data(request),
      onError: (error, stackTrace) =>
          state = AsyncValue.error(error, stackTrace),
    );
  }

  Future<void> acceptRequest(String requestId, String senderId) async {
    await _chatServices.acceptMessageRequest(requestId, senderId);
    _init();
  }

  Future<void> rejectRequest(String requestId) async {
    await _chatServices.rejectMessageRequest(requestId);
    _init();
  }

  void refresh() => _init();
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final requestProvider =
    StateNotifierProvider<
      RequestNotifier,
      AsyncValue<List<MessageRequestModel>>
    >((ref) {
      final service = ref.watch(chatServiceProvider);
      return RequestNotifier(service);
    });

/// ------------------------ AUTO  REFRESH ON AUTH CHANGE -----------------

final autoRefreshProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<User?>>(authStateProvider, (prev, next) {
    next.whenData((user) {
      if (user != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          ref.invalidate(contactProvider);
          ref.invalidate(requestProvider);
        });
      }
    });
  });
});

///------------------------------CHAT------------------------
class ChatsNotifier extends StateNotifier<AsyncValue<List<ChatModel>>> {
  final ChatServices chatService;
  StreamSubscription<List<ChatModel>>? _subscription;
  ChatsNotifier(this.chatService) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _subscription?.cancel();
    _subscription = chatService.getUserChats().listen(
      (chats) => state = AsyncValue.data(chats),
      onError: (error, stackTrace) =>
          state = AsyncValue.error(error, stackTrace),
    );
  }

  void refresh() => _init();
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final chatsProvider =
    StateNotifierProvider<ChatsNotifier, AsyncValue<List<ChatModel>>>((ref) {
      final service = ref.watch(chatServiceProvider);
      return ChatsNotifier(service);
    });

///------------------------------SEARCH-------------------------
final searchQueryProvider = StateProvider<String>((ref) => '');
final filteredUsersProvider = Provider<AsyncValue<List<UserModel>>>((ref) {
  final user = ref.watch(contactProvider);
  final query = ref.watch(searchQueryProvider);
  return user.when(
    data: (list) {
      if (query.isEmpty) return AsyncValue.data(list);
      return AsyncValue.data(
        list.where((user) {
          return user.name.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase());
        }).toList(),
      );
    },
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    loading: () => AsyncValue.loading(),
  );
});

///------------------------------Typing Indicator-------------------------
class TypingNotifier extends StateNotifier<Map<String, bool>> {
  final ChatServices chatService;
  StreamSubscription<Map<String, bool>>? _subscription;
  final String chatId;
  TypingNotifier(this.chatService, this.chatId) : super({}) {
    _listenToTypingStatus();
  }

  void _listenToTypingStatus() {
    _subscription?.cancel();
    _subscription = chatService
        .getTypingStatus(chatId)
        .listen(
          (typingData) => state = Map<String, bool>.from(typingData),
          onError: (error, stackTrace) => state = {},
        );
  }

  Future<void> setTyping(bool isTyping) async {
    await chatService.setTypingStatus(chatId, isTyping);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final typingProvider =
    StateNotifierProvider.family<TypingNotifier, Map<String, bool>, String>((
      ref,
      chatId,
    ) {
      final service = ref.watch(chatServiceProvider);
      return TypingNotifier(service, chatId);
    });
