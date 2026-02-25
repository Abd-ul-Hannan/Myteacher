import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Create new conversation
  static Future<String> createConversation(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .add({
      "title": "New Chat",
      "createdAt": FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // 🔹 Save message
  static Future<void> saveMessage({
    required String userId,
    required String conversationId,
    required String text,
    required bool isUser,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add({
      "text": text,
      "isUser": isUser,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  // 🔹 Stream messages
  static Stream<QuerySnapshot> messagesStream(
      String userId, String conversationId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  // 🔹 Stream conversations
  static Stream<QuerySnapshot> conversationsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 🔹 Delete user data (all conversations)
  static Future<void> deleteUserData(String userId) async {
    final convs = await _firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .get();

    for (var doc in convs.docs) {
      final messages = await doc.reference.collection('messages').get();
      for (var msg in messages.docs) {
        await msg.reference.delete();
      }
      await doc.reference.delete();
    }

    await _firestore.collection('users').doc(userId).delete();
  }

  // 🔹 Delete single conversation
  static Future<void> deleteConversation(
      String userId, String conversationId) async {
    final messages = await _firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .get();
    for (var msg in messages.docs) {
      await msg.reference.delete();
    }
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(conversationId)
        .delete();
  }
}
