import 'dart:async';
import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image/image.dart' as img;
import 'package:image2pdf_pro/images_list.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class SelectedImages extends StatefulWidget {
  final ImagesList imagesList;

  const SelectedImages({Key? key, required this.imagesList}) : super(key: key);

  @override
  State<SelectedImages> createState() => _SelectedImagesState();
}

class _SelectedImagesState extends State<SelectedImages> {
  late double progressValue = 0;
  late bool isExporting = false;
  late int convertedImage = 0;
  late String fileName = '';

  Future<void> _showFileNameDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String inputFileName = '';
        return AlertDialog(
          title: const Text('Enter PDF Name'),
          content: TextField(
            onChanged: (value) {
              inputFileName = value;
            },
            decoration: const InputDecoration(
              hintText: 'Enter PDF Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(inputFileName);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      debugPrint("result $result");
      setState(() {
        fileName = result;
      });
      convertImage();
    }
  }

  Future<void> convertImage() async {
    if (fileName.isEmpty) {
      await _showFileNameDialog();
      return;
    }

    // Request permission to access external storage
    var status = await Permission.storage.request();
    if (status.isDenied) {
      // Permission denied by user
      return;
    }

    setState(() {
      isExporting = true;
    });

    final pathToSave = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOCUMENTS);
    debugPrint("pathToSave $pathToSave");
    final pdf = pw.Document();

    for (final imagePath in widget.imagesList.imagePaths) {
      final imageBytes = await File(imagePath.path).readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image != null) {
        final pdfImage = pw.MemoryImage(imageBytes);
        pdf.addPage(
          pw.Page(build: (pw.Context context) {
            return pw.Center(child: pw.Image(pdfImage));
          }),
        );
      }

      setState(() {
        convertedImage++;
        progressValue = convertedImage / widget.imagesList.imagePaths.length;
      });
    }

    final outputFile = File('$pathToSave/$fileName.pdf');
    await outputFile.writeAsBytes(await pdf.save());

    MediaScanner.loadMedia(path: outputFile.path);

    if (mounted) {
      setState(() {
        isExporting = false;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('PDF Saved'),
            content: Text(
                'Success!  PDF saved to your document directory as $fileName.pdf'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate back to the home screen after PDF saved
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Selected Images"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 233, 6, 6),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          if (!isExporting)
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Gap(10),
                  Visibility(
                    visible: !isExporting,
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemCount: widget.imagesList.imagePaths.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Image.file(
                          File(widget.imagesList.imagePaths[index].path),
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          if (isExporting)
            Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: const Color.fromARGB(255, 2, 2, 2),
                size: 100,
              ),
            ),
        ],
      ),
      bottomNavigationBar: Visibility(
        visible: !isExporting,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: MaterialButton(
            color: const Color.fromARGB(255, 238, 9, 9),
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            onPressed: () => convertImage(),
            child: const Text(
              'Convert',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}
