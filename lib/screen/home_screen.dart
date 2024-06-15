import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pick_image_file/screen/selected_model.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final croppedFile = await _cropImage(pickedFile.path);

      if (croppedFile != null) {
        Provider.of<FileModel>(context, listen: false)
            .setSelectedImage(croppedFile.path);
        Provider.of<FileModel>(context, listen: false).setSelectedFile(null);
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final croppedFile = await _cropImage(pickedFile.path);

      if (croppedFile != null) {
        Provider.of<FileModel>(context, listen: false)
            .setSelectedImage(croppedFile.path);
        Provider.of<FileModel>(context, listen: false).setSelectedFile(null);
      }
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        Provider.of<FileModel>(context, listen: false)
            .setSelectedFile(filePath);
        Provider.of<FileModel>(context, listen: false).setSelectedImage(null);
      }
    }
  }

  Future<CroppedFile?> _cropImage(String sourcePath) async {
    return await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 100,
      maxWidth: 1080,
      maxHeight: 1080,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff657194),
      appBar: AppBar(
        backgroundColor: const Color(0xff657194),
        title: const Text(
          'Select Image & File',
          style: TextStyle(
            color: Color(0xffE9FBFF),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30,right: 30,top: 20),
              child: Consumer<FileModel>(
                builder: (context, fileModel, child) {
                  if (fileModel.selectedImage != null) {
                    final imagePath = fileModel.selectedImage!;
                    if (imagePath.isNotEmpty && File(imagePath).existsSync()) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.file(File(imagePath)),
                      );
                    } else {
                      return const Text(
                        'Image path is invalid or file does not exist.',
                        style: TextStyle(color: Colors.red),
                      );
                    }
                  } else if (fileModel.selectedFile != null) {
                    final filePath = fileModel.selectedFile!;
                    return Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _getFileIcon(filePath),
                          const Gap(20),
                          Text(
                            'Selected File: ${filePath.split('/').last}',
                            style: const TextStyle(
                              color: Color(0xffE9FBFF),
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const Column(
                      children: [
                        Gap(150),
                        Icon(
                          Icons.image_outlined,
                          size: 200,
                          color: Color(0xffE9FBFF),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
            const Gap(20),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: _pickImageFromGallery,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xffE9FBFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Select Image',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff638f91),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickImageFromCamera,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xffE9FBFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Capture Image',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff638f91),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(30),
                GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xffE9FBFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Select File',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff638f91),
                      ),
                    ),
                  ),
                ),
                const Gap(30),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getFileIcon(String filePath) {
    String extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return const Icon(
          Icons.picture_as_pdf,
          size: 100,
          color: Color(0xff0a1730),
        );
      case 'mp4':
      case 'avi':
      case 'mkv':
        return const Icon(
          Icons.videocam,
          size: 100,
          color: Color(0xff0a1730),
        );
      case 'doc':
      case 'docx':
      case 'txt':
        return const Icon(
          Icons.text_snippet,
          size: 100,
          color: Color(0xffe9ac75),
        );
      default:
        return const Icon(
          Icons.insert_drive_file,
          size: 100,
          color: Color(0xff78c9ae),
        );
    }
  }
}
