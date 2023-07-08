// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  Future<File>? imageFile;
  File? _image;
  String result = "";
  ImagePicker? imagePicker;

  selectPhotoFromGallery() async {
    XFile? pickedFile =
        await imagePicker!.pickImage(source: ImageSource.gallery);
    _image = File(pickedFile!.path);
    setState(() {
      _image;
      doImageClassification();
    });
  }

  capturePhotoFromCamera() async {
    XFile? pickedFile =
        await imagePicker!.pickImage(source: ImageSource.camera);
    _image = File(pickedFile!.path);
    setState(() {
      _image;
      doImageClassification();
    });
  }

  loadDataModelFiles() async {
    String? output = await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
    print(output);
  }

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    loadDataModelFiles();
  }

  doImageClassification() async {
    print("do image is run");
    var recognitions = await Tflite.runModelOnImage(
        path: _image!.path,
        imageMean: 127.5,
        imageStd: 127.5,
        numResults: 6,
        threshold: 0.0,
        asynch: true);
    print(recognitions!.length.toString());
    setState(() {
      result = "";
    });
    recognitions.forEach((element) {
      setState(() {
        print(element.toString());
        result += element['label'] +
            '  ' +
            (element["confidence"] * 100 as double).toStringAsFixed(2) +
            "%" +
            '\n\n';
        print("result = $result");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Detection"),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Stack(
              children: [
                Center(
                  child: TextButton(
                      onPressed: selectPhotoFromGallery,
                      onLongPress: capturePhotoFromCamera,
                      child: Container(
                        margin:
                            const EdgeInsets.only(top: 30, right: 30, left: 18),
                        child: _image != null
                            ? Image.file(
                                _image!,
                                height: 360,
                                width: 400,
                                fit: BoxFit.cover,
                              )
                            : const SizedBox(
                                width: 140,
                                height: 190,
                                child: Icon(Icons.camera),
                              ),
                      )),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 100,
          ),
          Text(result),
        ],
      ),
    );
  }
}
