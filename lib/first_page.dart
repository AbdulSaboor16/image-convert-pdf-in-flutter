import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final picker = ImagePicker();
  final pdf = pw.Document();
  List<File> _images = [];
  
    File? _imageFile;
  Future<void> _takePicture() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _saveToGallery() async {
    if (_imageFile != null) {
      final result = await ImageGallerySaver.saveFile(_imageFile!.path);
      print('Image saved to gallery: $result');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image to PDF"),
        actions: [
          IconButton(
            onPressed: openGallery,
            icon: const Icon(Icons.photo_library),
          ),
          IconButton(
            onPressed: openCamera,
            icon: const Icon(Icons.camera_alt),
          ),
          IconButton(
            onPressed: () {
              createPDF();
              savePDF();
            },
            icon: const Icon(Icons.picture_as_pdf),
          ),
        ],
      ),
      body: _images.isNotEmpty
          ? ListView.builder(
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final image = _images[index];
                return Container(
                  height: 400,
                  width: double.infinity,
                  margin: const EdgeInsets.all(8),
                  child: Image.file(
                    image,
                    fit: BoxFit.cover,
                  ),
                );
              },
            )
          : Container(),
    );
  }

  openGallery() async {
    final pickedImages = await ImagePicker().pickMultiImage(
      maxWidth: 800,
      imageQuality: 80,
    );

    if (pickedImages == null) return;

    setState(() {
      _images.clear();
      for (var image in pickedImages) {
        _images.add(File(image.path));
      }
    });
  }

  openCamera() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      imageQuality: 80,
    );

    if (pickedImage == null) return;

    final imageFile = File(pickedImage.path);
    setState(() {
      _images.add(imageFile);
    });
  }

  createPDF() async {
    if (_images.isEmpty) {
      return;
    }

    for (var imageFile in _images) {
      final image = pw.MemoryImage(imageFile.readAsBytesSync());
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(image));
          },
        ),
      );
    }
  }

  savePDF() async {
    if (_images.isEmpty) {
      print("No images to save as PDF");
      return;
    }

    try {
      final pdf = pw.Document();

      for (var imageFile in _images) {
        final image = pw.MemoryImage(imageFile.readAsBytesSync());
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(child: pw.Image(image));
            },
          ),
        );
      }

      final dir = await getExternalStorageDirectory();
      final file = File("${dir?.path}/filename.pdf");
      await file.writeAsBytes(await pdf.save());
      showPrintedMessage('Success', 'Saved to documents android folder then data folder pdf format');
    } catch (e) {
     
      showPrintedMessage('Error', e.toString());
    }
  }

  showPrintedMessage(String title, String msg) {
    Flushbar(
      title: title,
      message: msg,
      duration: const Duration(seconds: 3),
      icon: const Icon(
        Icons.info,
        color: Colors.blue,
      ),
    ).show(context);
  }
}