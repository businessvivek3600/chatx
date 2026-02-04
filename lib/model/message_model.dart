import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String chatId;              // ✅ REQUIRED
  final String senderId;
  final String senderName;
  final String receiverId;          // ✅ REQUIRED FOR CALLS
  final String receiverName;        // ✅ REQUIRED FOR CALLS
  final String message;
  final DateTime? timestamp;
  final String type;
  final Map<String, DateTime>? readBy;
  final String? imageUrl;
  final String? callType;
  final String? callStatus;
  final int? duration;
  final String? reaction;

  MessageModel({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.message,
    this.type = 'text',
    this.timestamp,
    this.readBy,
    this.imageUrl,
    this.callType,
    this.callStatus,
    this.duration,
    this.reaction,
  });

  /// Firestore → MessageModel
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    final rawReadBy = map['readBy'];
    Map<String, DateTime> parsedReadBy = {};

    if (rawReadBy != null && rawReadBy is Map) {
      rawReadBy.forEach((key, value) {
        if (value is Timestamp) {
          parsedReadBy[key] = value.toDate();
        }
      });
    }

    return MessageModel(
      messageId: map['messageId'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'text',
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : null,
      readBy: parsedReadBy,
      imageUrl: map['imageUrl'],
      callType: map['callType'],
      callStatus: map['callStatus'],
      duration: map['duration'],
      reaction: map['reaction'],
    );
  }

  /// MessageModel → Firestore
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'message': message,
      'type': type,
      'timestamp':
          timestamp != null ? Timestamp.fromDate(timestamp!) : null,
      'readBy': readBy?.map(
        (key, value) => MapEntry(key, Timestamp.fromDate(value)),
      ),
      'imageUrl': imageUrl,
      'callType': callType,
      'callStatus': callStatus,
      'duration': duration,
      'reaction': reaction,
    };
  }

  /// Copy helper (for reactions etc.)
  MessageModel copyWith({
    String? reaction,
    String? callStatus,
    int? duration,
  }) {
    return MessageModel(
      messageId: messageId,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      receiverName: receiverName,
      message: message,
      type: type,
      timestamp: timestamp,
      readBy: readBy,
      imageUrl: imageUrl,
      callType: callType,
      callStatus: callStatus ?? this.callStatus,
      duration: duration ?? this.duration,
      reaction: reaction ?? this.reaction,
    );
  }
}
