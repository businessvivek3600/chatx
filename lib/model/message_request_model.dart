class MessageRequestModel {
  final String id;
  final String senderUid;
  final String receiverUid;
  final String senderName;
  final String senderEmail;
  final String status; // pending | accepted | rejected
  final DateTime createdAt;
  final String? photoUrl;
  final String? reaction; // 👍 ❤️ 😂 😢 etc

  const MessageRequestModel({
    required this.id,
    required this.senderUid,
    required this.receiverUid,
    required this.senderName,
    required this.senderEmail,
    required this.status,
    required this.createdAt,
    this.photoUrl,
    this.reaction,
  });

  /// FROM FIRESTORE
  factory MessageRequestModel.fromMap(Map<String, dynamic> map) {
    return MessageRequestModel(
      id: map['id'] ?? '',
      senderUid: map['senderUid'] ?? '',
      receiverUid: map['receiverUid'] ?? '',
      senderName: map['senderName'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      status: map['status'] ?? '',
      createdAt: map['createdAt'] != null
          ? map['createdAt'].toDate()
          : DateTime.now(),
      photoUrl: map['photoUrl'],
      reaction: map['reaction'],
    );
  }

  /// TO FIRESTORE
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'senderName': senderName,
      'senderEmail': senderEmail,
      'status': status,
      'createdAt': createdAt,
      'photoUrl': photoUrl,
      'reaction': reaction,
    };
  }

  /// COPY WITH
  MessageRequestModel copyWith({
    String? reaction,
    String? status,
  }) {
    return MessageRequestModel(
      id: id,
      senderUid: senderUid,
      receiverUid: receiverUid,
      senderName: senderName,
      senderEmail: senderEmail,
      status: status ?? this.status,
      createdAt: createdAt,
      photoUrl: photoUrl,
      reaction: reaction ?? this.reaction,
    );
  }
}
