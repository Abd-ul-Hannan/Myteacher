import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_teacher/services/firebase_services.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  
  Rx<User?> firebaseUser = Rx<User?>(null);
  RxBool isLoading = false.obs;
  RxBool isDeletingAccount = false.obs; // New: Track deletion state

  @override
  void onInit() {
    firebaseUser.bindStream(_auth.authStateChanges());
    super.onInit();
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      
      await _googleSignIn.initialize();
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      
      final authClient = googleUser.authorizationClient;
      final authorization = await authClient.authorizationForScopes(['email', 'profile']);
      
      if (authorization == null) {
        isLoading.value = false;
        Get.snackbar("Error", "Authorization failed");
        return;
      }
      
      final idToken = googleUser.authentication.idToken;
      final credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: idToken,
      );

      await _auth.signInWithCredential(credential);
      Get.offAllNamed("/chat");
      
    } catch (e) {
      Get.snackbar(
        "Error", 
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _auth.signOut();
      await _googleSignIn.signOut();
      Get.offAllNamed("/login");
    } catch (e) {
      Get.snackbar("Error", "Sign out failed");
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // DELETE ACCOUNT WITH PROPER CONFIRMATION
  // ============================================
  Future<void> deleteAccountWithConfirmation() async {
    // Prevent multiple deletion attempts
    if (isDeletingAccount.value) return;

    // Show confirmation dialog (non-dismissible)
    final bool? confirm = await Get.dialog<bool>(
      WillPopScope(
        // Prevent back button from closing dialog
        onWillPop: () async => false,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text("Delete Account?"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "This will permanently delete:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text("• All your conversations"),
              Text("• All your messages"),
              Text("• Your profile data"),
              Text("• Your account"),
              SizedBox(height: 16),
              Text(
                "⚠️ This action CANNOT be undone!",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text("Delete Forever"),
            ),
          ],
        ),
      ),
      barrierDismissible: false, // Can't dismiss by tapping outside
    );

    // If user confirmed, start deletion
    if (confirm == true) {
      await _performAccountDeletion();
    }
  }

  // ============================================
  // ACTUAL DELETION LOGIC (SEPARATE FUNCTION)
  // ============================================
  Future<void> _performAccountDeletion() async {
    isDeletingAccount.value = true;
    
    // Show loading dialog (non-dismissible)
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent back button
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Deleting your account..."),
              SizedBox(height: 8),
              Text(
                "Please don't close the app",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // Can't dismiss by tapping outside
    );

    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        Get.back(); // Close loading dialog
        Get.snackbar("Error", "No user logged in");
        return;
      }

      print("🗑️ Starting account deletion for: ${user.uid}");

      // Step 1: Re-authenticate user
      print("🔐 Re-authenticating user...");
      await _reauthenticateUser();
      
      // Step 2: Delete Firestore data
      print("📦 Deleting Firestore data...");
      await FirebaseService.deleteUserData(user.uid);
      print("✅ Firestore data deleted");
      
      // Step 3: Delete Firebase Auth account
      print("👤 Deleting Firebase Auth account...");
      await user.delete();
      print("✅ Auth account deleted");
      
      // Step 4: Sign out from Google
      print("🔓 Signing out from Google...");
      await _googleSignIn.signOut();
      print("✅ Google sign out complete");

      // Close loading dialog
      Get.back();

      // Navigate to login screen
      Get.offAllNamed("/login");
      
      // Show success message
      Get.snackbar(
        "Account Deleted", 
        "Your account has been permanently deleted",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      
    } on FirebaseAuthException catch (e) {
      Get.back(); // Close loading dialog
      print("❌ FirebaseAuthException: ${e.code} - ${e.message}");
      
      if (e.code == 'requires-recent-login') {
        Get.snackbar(
          "Error", 
          "Session expired. Please sign in again and try deleting.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
        await signOut();
      } else {
        Get.snackbar(
          "Error", 
          "Delete failed: ${e.message}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      print("❌ General Exception: $e");
      
      Get.snackbar(
        "Error", 
        "Cannot delete account. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isDeletingAccount.value = false;
    }
  }

  // ============================================
  // RE-AUTHENTICATE USER
  // ============================================
  Future<void> _reauthenticateUser() async {
    try {
      print("🔄 Re-authenticating with Google...");
      
      await _googleSignIn.initialize();
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      
      final authClient = googleUser.authorizationClient;
      final authorization = await authClient.authorizationForScopes(['email', 'profile']);
      
      if (authorization == null) {
        throw Exception("Re-authentication failed: No authorization");
      }
      
      final idToken = googleUser.authentication.idToken;
      final credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: idToken,
      );

      final user = _auth.currentUser;
      if (user != null) {
        await user.reauthenticateWithCredential(credential);
        print("✅ Re-authentication successful");
      }
      
    } catch (e) {
      print("❌ Re-authentication failed: $e");
      throw Exception("Re-authentication failed. Please try again.");
    }
  }

  // ============================================
  // SIMPLE DELETE (WITHOUT CONFIRMATION)
  // Use this if you handle confirmation in UI
  // ============================================
  Future<void> deleteAccount() async {
    await _performAccountDeletion();
  }
}
