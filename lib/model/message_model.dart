import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime? timestamp;
  final String type;
  final Map<String, DateTime>? readBy;
  final String? imageUrl;
  final String? callType;
  final String? callStatus;
  final int? duration;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.message,
    this.type = 'text',
    this.timestamp,
    this.readBy,
    this.imageUrl,
    this.callType,
    this.callStatus,
    this.duration,
  });

  /// Map → MessageModel
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    final rawReadBy = map['readBy'];

    Map<String, DateTime> parsedReadBy = {};

    if (rawReadBy != null && rawReadBy is Map) {
      rawReadBy.forEach((key, value) {
        if (value is Timestamp) {
          parsedReadBy[key] = value.toDate();
        } else if (value is DateTime) {
          parsedReadBy[key] = value;
        }
      });
    }
    return MessageModel(
      messageId: map['messageId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'user',
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : map['timestamp'],
      readBy: parsedReadBy,
      imageUrl: map['imageUrl'],
      callType: map['callType'],
      callStatus: map['callStatus'],
      duration: map['duration'],
    );
  }

  /// MessageModel → Map
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'type': type,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
      'readBy': readBy?.map(
        (key, value) => MapEntry(key, Timestamp.fromDate(value)),
      ),
      'imageUrl': imageUrl,
      'callType': callType,
      'callStatus': callStatus,
      'duration': duration,
    };
  }
}
