import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_teacher/controllers/auth_controllers.dart';
import '../controllers/theme_controllers.dart';
import '../app/themes.dart';

class LoginScreen extends StatelessWidget {
  final authController = Get.put(AuthController());
  final themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "My Teacher",
              style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text("Sign in with Google"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemes.primaryColor,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 24),
                  textStyle: const TextStyle(fontSize: 18)),
              onPressed: authController.signInWithGoogle,
            ),
            const SizedBox(height: 20),
            Obx(
              () => SwitchListTile(
                  title: const Text("Dark Mode"),
                  value: themeController.isDarkMode.value,
                  onChanged: (val) => themeController.toggleTheme()),
            ),
          ],
        ),
      ),
    );
  }
}
