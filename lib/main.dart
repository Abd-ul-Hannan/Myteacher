import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_teacher/app/routes.dart';
import 'package:my_teacher/app/themes.dart';
import 'package:my_teacher/controllers/theme_controllers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final themeController = Get.put(ThemeController());

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final Widget initialScreen =
        currentUser != null ? ChatScreen() : LoginScreen();

    return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: "My Teacher",
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeController.isDarkMode.value
              ? ThemeMode.dark
              : ThemeMode.light,
          home: initialScreen,
          getPages: AppRoutes.routes,
        ));
  }
}
