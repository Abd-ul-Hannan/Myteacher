import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_teacher/services/firebase_services.dart';
import '../services/ai_service.dart';

class ChatController extends GetxController {
  String get userId => FirebaseAuth.instance.currentUser?.uid ?? "";

  var messages = <Map<String, dynamic>>[].obs;
  var conversations = <Map<String, dynamic>>[].obs;

  var currentConversationId = "".obs;
  var isLoading = false.obs;
  var error = "".obs;

  final textController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    if (userId.isNotEmpty) {
      loadConversations();
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  void loadConversations() {
    if (userId.isEmpty) return;

    FirebaseService.conversationsStream(userId).listen(
      (snapshot) {
        conversations.value = snapshot.docs.map((doc) {
          return {
            "id": doc.id,
            "title": doc["title"] ?? "Untitled Chat",
          };
        }).toList();

        // Auto-open first conversation if none is selected
        if (currentConversationId.isEmpty && conversations.isNotEmpty) {
          openConversation(conversations.first["id"]);
        }
        
        // If current conversation was deleted, clear it
        if (currentConversationId.isNotEmpty &&
            !conversations.any((c) => c["id"] == currentConversationId.value)) {
          currentConversationId.value = "";
          messages.clear();
        }
      },
      onError: (error) {
        print("❌ Error loading conversations: $error");
        this.error.value = "Failed to load conversations";
      },
    );
  }

  void openConversation(String conversationId) {
    if (userId.isEmpty || conversationId.isEmpty) return;

    currentConversationId.value = conversationId;
    messages.clear();
    error.value = "";

    FirebaseService.messagesStream(userId, conversationId).listen(
      (snapshot) {
        messages.value = snapshot.docs.map((doc) {
          return {
            "text": doc["text"] ?? "",
            "user": doc["isUser"] ?? false,
          };
        }).toList();
      },
      onError: (error) {
        print("❌ Error loading messages: $error");
        this.error.value = "Failed to load messages";
      },
    );
  }

  Future<void> newChat() async {
    if (userId.isEmpty) {
      error.value = "Please sign in first";
      return;
    }

    try {
      final id = await FirebaseService.createConversation(userId);
      openConversation(id);
      
      Get.snackbar(
        "New Chat",
        "Created successfully",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      print("❌ Error creating conversation: $e");
      error.value = "Failed to create new chat";
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    if (userId.isEmpty || conversationId.isEmpty) return;

    try {
      print("🗑️ Deleting conversation: $conversationId");
      
      await FirebaseService.deleteConversation(userId, conversationId);
      
      // Clear current conversation if it was deleted
      if (currentConversationId.value == conversationId) {
        currentConversationId.value = "";
        messages.clear();
        
        // Open first remaining conversation if any
        if (conversations.isNotEmpty) {
          final remaining = conversations.where((c) => c["id"] != conversationId).toList();
          if (remaining.isNotEmpty) {
            openConversation(remaining.first["id"]);
          }
        }
      }
      
      print("✅ Conversation deleted successfully");
    } catch (e) {
      print("❌ Error deleting conversation: $e");
      error.value = "Failed to delete conversation";
      
      Get.snackbar(
        "Error",
        "Could not delete conversation",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> sendMessage() async {
    final msg = textController.text.trim();
    
    if (msg.isEmpty) {
      error.value = "Please enter a message";
      return;
    }
    
    if (userId.isEmpty) {
      error.value = "Please sign in first";
      return;
    }

    // Create new conversation if none exists
    if (currentConversationId.isEmpty) {
      await newChat();
      // Wait a bit for conversation to be created
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (currentConversationId.isEmpty) {
      error.value = "Failed to create conversation";
      return;
    }

    try {
      isLoading.value = true;
      error.value = "";
      textController.clear();

      print("📤 Sending user message...");
      
      // Save user message
      await FirebaseService.saveMessage(
        userId: userId,
        conversationId: currentConversationId.value,
        text: msg,
        isUser: true,
      );

      print("🤖 Getting AI reply...");
      
      // Get AI response
      final reply = await AIService.getReply(msg);

      print("💾 Saving AI reply...");
      
      // Save AI response
      await FirebaseService.saveMessage(
        userId: userId,
        conversationId: currentConversationId.value,
        text: reply,
        isUser: false,
      );

      print("✅ Message sent successfully");
    } catch (e) {
      print("❌ Error sending message: $e");
      error.value = "Something went wrong. Try again.";
      
      Get.snackbar(
        "Error",
        "Failed to send message: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }
}