import 'package:flutter/material.dart';

class FileModel with ChangeNotifier {
  String? _selectedImage;
  String? _selectedFile;

  String? get selectedImage => _selectedImage;
  String? get selectedFile => _selectedFile;

  void setSelectedImage(String? image) {
    _selectedImage = image;
    notifyListeners();
  }

  void setSelectedFile(String? file) {
    _selectedFile = file;
    notifyListeners();
  }
}
