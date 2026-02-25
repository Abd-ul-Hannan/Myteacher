import 'package:get/get.dart';
import '../screens/login_screen.dart';
import '../screens/chat_screen.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: "/login", page: () => LoginScreen()),
    GetPage(name: "/chat", page: () => ChatScreen()),
  ];
}
