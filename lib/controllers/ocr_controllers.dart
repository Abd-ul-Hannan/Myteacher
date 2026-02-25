import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrController extends GetxController {
  final picker = ImagePicker();
  final textRecognizer = TextRecognizer();

  Future<String> getText(ImageSource source) async {
    try {
      final image = await picker.pickImage(source: source);
      if (image == null) return "";

      final input = InputImage.fromFilePath(image.path);
      final result = await textRecognizer.processImage(input);
      return result.text;
    } catch (e) {
      Get.snackbar("OCR Error", e.toString());
      return "";
    }
  }
}
