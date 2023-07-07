
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';



class PictureScreen extends StatefulWidget {
  const PictureScreen({super.key});

  @override
  _PictureScreenState createState() => _PictureScreenState();
}

class _PictureScreenState extends State<PictureScreen> {
  File? _imageFile;
  final picker = ImagePicker();

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
        title: Text('Take Picture'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_imageFile != null)
              Image.file(
                _imageFile!,
                width: 300,
                height: 300,
              ),
            ElevatedButton(
              onPressed: _takePicture,
              child: Text('Take Picture'),
            ),
            ElevatedButton(
              onPressed: _saveToGallery,
              child: Text('Save to Gallery'),
            ),
          ],
        ),
      ),
    );
  }
}

