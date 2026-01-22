import 'dart:ui';

import 'package:chatx/providers/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

ZegoSendCallInvitationButton actionButton(
  bool isVideo,
  String receiverId,
  String receiverName,
    WidgetRef ref,
    String chatId,
) => ZegoSendCallInvitationButton(
  invitees: [ZegoUIKitUser(id: receiverId, name: receiverName)],
  iconSize: Size(30, 30),
  buttonSize: Size(40, 50),
  resourceID: "chatx_call",
  isVideoCall: isVideo,
  onPressed: (code, message, errorInvitees) {
    final chatServices= ref.read(chatServiceProvider);
    chatServices.addCallHistory(
      chatId: chatId,
      isVideoCall: isVideo,
      callStatus: '_',
    );
  },
);
