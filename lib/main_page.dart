import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image2pdf_pro/images_list.dart';
import 'package:image2pdf_pro/selected_images.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final ImagesList imagesList = ImagesList();

  Future<PermissionStatus> storagePermissionStatus() async {
    PermissionStatus storagePermissionStatus = await Permission.storage.status;

    if (!storagePermissionStatus.isGranted) {
      await Permission.storage.request();
    }

    storagePermissionStatus = await Permission.storage.status;

    return storagePermissionStatus;
  }

  Future<PermissionStatus> cameraPermissionStatus() async {
    PermissionStatus cameraPermissionStatus = await Permission.camera.status;

    if (!cameraPermissionStatus.isGranted) {
      await Permission.camera.request();
    }

    cameraPermissionStatus = await Permission.camera.status;

    return cameraPermissionStatus;
  }

  void pickGalleryImage() async {
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickMultiImage();
    if (image.isNotEmpty) {
      imagesList.clearImagesList();
      imagesList.imagePaths.addAll(image);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectedImages(imagesList: imagesList),
        ),
      );
    }
  }

  void captureCameraImages() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      imagesList.clearImagesList();
      imagesList.imagePaths.add(image);
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectedImages(imagesList: imagesList),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image to PDF Converter"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 238, 9, 9),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MaterialButton(
              color: const Color.fromARGB(255, 238, 9, 9),
              textColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              onPressed: pickGalleryImage,
              child:
                  const Text("Gallery Images", style: TextStyle(fontSize: 18)),
            ),
            const Gap(20),
            MaterialButton(
              color: const Color.fromARGB(255, 238, 9, 9),
              textColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              onPressed: captureCameraImages,
              child:
                  const Text("Capture Image", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
