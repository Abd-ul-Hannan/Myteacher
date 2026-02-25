import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime lastMessageTime;

  Conversation({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.lastMessageTime,
  });

  factory Conversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Conversation(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? 'New Chat',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
    };
  }
}