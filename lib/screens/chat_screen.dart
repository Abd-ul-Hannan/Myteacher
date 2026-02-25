import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_teacher/controllers/chat_controllers.dart';
import 'package:my_teacher/controllers/auth_controllers.dart';
import 'package:my_teacher/controllers/ocr_controllers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_teacher/widgets/chat_bubbles.dart';

class ChatScreen extends StatelessWidget {
  final controller = Get.put(ChatController());
  final authController = Get.put(AuthController());
  final ocrController = Get.put(OcrController());

  ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Prevent back button when deleting account
      onWillPop: () async {
        return !authController.isDeletingAccount.value;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Teacher"),
          actions: [
            // 🔹 DELETE ACCOUNT BUTTON (PROFESSIONAL)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'delete_account') {
                  await authController.deleteAccount();
                } else if (value == 'logout') {
                  authController.signOut();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete_account',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Account', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        drawer: Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blue.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "My Teacher",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("New Chat"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        controller.newChat();
                        Get.back();
                      },
                    )
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.conversations.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            "No chats yet",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.conversations.length,
                    itemBuilder: (_, i) {
                      final convo = controller.conversations[i];
                      final isSelected = controller.currentConversationId.value == convo["id"];
                      
                      return Container(
                        color: isSelected ? Colors.blue.withOpacity(0.1) : null,
                        child: ListTile(
                          title: Text(
                            convo["title"],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          leading: Icon(
                            Icons.chat,
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _showDeleteConversationDialog(convo["id"]),
                          ),
                          onTap: () {
                            controller.openConversation(convo["id"]);
                            Get.back();
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),

        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Obx(() {
                    if (controller.messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            const Text(
                              "Start a conversation with My Teacher",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Ask anything, upload images, or take photos!",
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: controller.messages.length,
                      itemBuilder: (_, i) {
                        final msg = controller.messages[i];
                        return ChatBubble(
                          text: msg["text"],
                          isUser: msg["user"],
                        );
                      },
                    );
                  }),
                ),

                Obx(() => controller.error.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.red.shade50,
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controller.error.value,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () => controller.error.value = "",
                            ),
                          ],
                        ),
                      )
                    : const SizedBox()),

                // 🔹 INPUT BAR
                SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border(top: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.textController,
                            decoration: InputDecoration(
                              hintText: "Ask your teacher...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => controller.sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Obx(() => controller.isLoading.value
                            ? const Padding(
                                padding: EdgeInsets.all(8),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.send, color: Colors.blue),
                                onPressed: controller.sendMessage,
                              )),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 🔹 FLOATING OCR BUTTON
            Positioned(
              bottom: 80,
              right: 20,
              child: FloatingActionButton(
                heroTag: 'ocr_button',
                onPressed: () => _showImageSourceDialog(),
                backgroundColor: Colors.blue,
                child: const Icon(Icons.camera_alt, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 DELETE CONVERSATION DIALOG
  void _showDeleteConversationDialog(String conversationId) {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text("Delete Chat?"),
          ],
        ),
        content: const Text("Are you sure you want to delete this conversation?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteConversation(conversationId);
              Get.snackbar(
                "Chat Deleted",
                "Conversation removed successfully",
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // 🔹 IMAGE SOURCE DIALOG
  void _showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Select Image Source"),
        content: const Text("Choose where to get the image from:"),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.photo_library),
            label: const Text("Gallery"),
            onPressed: () async {
              Get.back();
              await _processOCR(ImageSource.gallery);
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text("Camera"),
            onPressed: () async {
              Get.back();
              await _processOCR(ImageSource.camera);
            },
          ),
        ],
      ),
    );
  }

  // 🔹 PROCESS OCR
  Future<void> _processOCR(ImageSource source) async {
    try {
      final text = await ocrController.getText(source);
      
      if (text.isNotEmpty) {
        controller.textController.text = text;
        await controller.sendMessage();
        
        Get.snackbar(
          "Text Extracted",
          "Text sent to My Teacher",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          "OCR Failed",
          "No text detected in the image",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to process image: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}