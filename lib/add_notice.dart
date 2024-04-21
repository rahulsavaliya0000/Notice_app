
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:studentsapp/utils.dart';

class AddNoticePage extends StatefulWidget {
  const AddNoticePage({Key? key}) : super(key: key);

  @override
  State<AddNoticePage> createState() => _AddNoticePageState();
}

class _AddNoticePageState extends State<AddNoticePage> {
  XFile? _image;
  final fire_ref = FirebaseFirestore.instance.collection("review");
  final Post = TextEditingController();
  final descriptionController = TextEditingController();
  bool _isLoading = false;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  void validate() {
    // nameTxt.text='lkp';
    if (formkey.currentState?.validate() == null) {
      print("ok");
    } else {
      print("error");
    }
  }

  Future<void> _imageFromCamera() async {
    XFile? image = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  Future<void> _imageFromGallery() async {
    XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  Future<String?> _uploadImageToFirebase() async {
    if (_image == null) {
      return null;
    }

    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('images/${path.basename(_image!.path)}');

    UploadTask uploadTask = storageReference.putFile(File(_image!.path));

    setState(() {
      _isLoading = true;
    });

    try {
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      setState(() {
        _isLoading = false;
      });

      return downloadUrl;
    } catch (error) {
      print("Upload Error: $error");
      setState(() {
        _isLoading = false;
      });
      return null;
    }
  }

  Future<void> _uploadDataToFirebase() async {
    if (Post.text.isEmpty || descriptionController.text.isEmpty) {
      // Validation check
      return Utils.toastMessageCenter("Write a Notice");
    }

    String? imageUrl = await _uploadImageToFirebase();

    String id = DateTime.now().microsecondsSinceEpoch.toString();
    await fire_ref.doc(id).set({
      'title': Post.text,
      'description': descriptionController.text,
      'id': id,
      'timestamp': DateTime.now(),
      'image_url': imageUrl,
    });

    setState(() {
      Post.clear();
      descriptionController.clear();
      _image = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Note added successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("Add Notice", style: TextStyle(fontWeight: FontWeight.w500,fontFamily: 'Metropolis')),
        centerTitle: true,
        backgroundColor: Colors.purple.shade200,
      ),
      backgroundColor:  Colors.purple.shade50,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Scrollbar(
                radius: const Radius.circular(10),
                interactive: true,
                thickness: 5,
                trackVisibility: true,
                child: Form(
                  // key: formkey,
                  child: TextFormField(
                    controller: Post,
                    decoration: InputDecoration(
                      hintText: "Enter your title",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      filled: true,
                      fillColor:  Colors.purple.shade200,
                    ),
                    // maxLines: 4,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "please enter your titel";
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Scrollbar(
                radius: const Radius.circular(10),
                interactive: true,
                thickness: 5,
                trackVisibility: true,
                child: Form(
                  key: formkey,
                  child: TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      hintText: "Enter your description",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      filled: true,
                      fillColor:  Colors.purple.shade200,
                    ),
                    maxLines: 4,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "please enter your description";
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            _image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.file(
                      File(_image!.path),
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black),
                      borderRadius: BorderRadius.circular(22),
                      color:  Colors.purple.shade200,
                    ),
                    child: Center(
                      child: Icon(Icons.image, size: 50),
                    ),
                  ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
  onPressed: _imageFromCamera,
  icon: Icon(
    Icons.camera,
    color: Colors.black,
  ),
  label: Text('Camera', style: TextStyle(color: Colors.black)),
  style: ElevatedButton.styleFrom(
    foregroundColor: Colors.black, backgroundColor: Colors.white, // Adjust text and icon color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0), // Adjust corner radius
      side: BorderSide(
        color: Colors.black, // Border color
        width: 1.0, // Border width
      ),
    ),
  ),
),
ElevatedButton.icon(
  onPressed: _imageFromGallery,
  icon: Icon(
    Icons.photo,
    color: Colors.black,
  ),
  label: Text('Gallery', style: TextStyle(color: Colors.black)),
  style: ElevatedButton.styleFrom(
    foregroundColor: Colors.black, backgroundColor: Colors.white, // Adjust text and icon color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0), // Adjust corner radius
      side: BorderSide(
        color: Colors.black, // Border color
        width: 1.0, // Border width
      ),
    ),
  ),
),

              ],
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _uploadDataToFirebase,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:  Colors.purple.shade200, // Adjust text color as desired
                shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0), // Adjust corner radius
      side: BorderSide(
        color: Colors.black, // Border color
        width: 1.0, // Border width
      ),
    ),
                padding: EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 12.0), // Adjust padding
              ),
              child: _isLoading
                  ? Container(
                      width: 24.0, // Adjust width for indicator size
                      height: 24.0, // Adjust height for indicator size
                      child: CircularProgressIndicator(
                        backgroundColor:
                            Colors.transparent, // Transparent background
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white), // White spinner
                      ),
                    )
                  : Text(
                      'Add Notice',
                      style: TextStyle(
                         fontFamily: 'Metropolis',
                         color: Colors.black87,
                        fontSize: 17.0, // Adjust font size
                        fontWeight: FontWeight.w600, // Adjust font weight
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
