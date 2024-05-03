import 'package:flutter/material.dart';
import 'package:image2pdf_pro/main_page.dart';

void main() {
  runApp(const Image2PdfPro());
}

class Image2PdfPro extends StatelessWidget {
  const Image2PdfPro({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}
