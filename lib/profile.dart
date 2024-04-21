// import 'dart:io';
//
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:hack/view/utils.dart';
// import 'package:image_picker/image_picker.dart';
//
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
//
//
// class ProfileView extends StatefulWidget {
//   const ProfileView({Key? key}) : super(key: key);
//
//   @override
//   State<ProfileView> createState() => _ProfileViewState();
// }
//
// class _ProfileViewState extends State<ProfileView> {
//   final auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   String photoUrl = ''; // Initially, the photoUrl will be empty
//   bool url=false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadProfileData(); // Load the profile data when the screen initializes
//   }
//
//   // Function to load the profile data
//   void _loadProfileData() {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       url=true;
//       setState(() {
//         photoUrl = user.photoURL ?? ''; // Assign the photoURL if available
//       });
//     }
//     else{
//       url=false;
//     }
//   }
//
//
//
//   Future<void> _updateProfilePhoto(File newImage) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       try {
//         String fileName =
//             'profile_photo_${user.uid}.jpg'; // Use the user's UID in the filename
//         final ref = firebase_storage.FirebaseStorage.instance
//             .ref()
//             .child('profile_photos')
//             .child(fileName);
//
//         // Check if the user already has a profile photo
//         if (user.photoURL != null && user.photoURL!.isNotEmpty) {
//           // If a previous photo exists, delete it from Firebase Storage
//           try {
//             await firebase_storage.FirebaseStorage.instance
//                 .refFromURL(user.photoURL!)
//                 .delete();
//           } catch (deleteError) {
//             print('Error deleting previous profile photo: $deleteError');
//           }
//         }
//
//         // Upload the new image to Firebase Storage
//         final task = await ref.putFile(newImage);
//
//         // Check if the upload task is successful
//         if (task.state == firebase_storage.TaskState.success) {
//           // Get the download URL for the uploaded image
//           final downloadUrl = await ref.getDownloadURL();
//
//           // Update the user's profile photo URL in Firebase
//           await user.updatePhotoURL(downloadUrl);
//
//           setState(() {
//             photoUrl = downloadUrl; // Update the photoUrl in the UI
//           });
//
//           Utils.toastMessage('Profile photo updated successfully.');
//         } else {
//           Utils.toastMessage('Error uploading profile photo. Please try again.');
//         }
//       } catch (error) {
//         // Handle any error that occurs during the profile photo update
//         print('Error updating profile photo: $error');
//         Utils.toastMessage('Error updating profile photo: $error');
//       }
//     }
//   }
//
//   // Function to open the image picker and update the profile photo
//   Future<void> _changePhotoButtonPressed() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//
//     if (pickedFile != null) {
//       // If the user picked a new photo, update the profile photo
//       File newImage = File(pickedFile.path);
//       _updateProfilePhoto(newImage);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//
//     // String photoUrl = user?.photoURL ?? 'default_url_if_photoURL_null';
//     String displayName = user?.displayName ?? 'Default Name';
//     String email = user?.email ?? 'Default Email';
//
//     void _updateDisplayNameFirebase(String newName) {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         user.updateDisplayName(newName).then((_) {
//           // Display name updated successfully
//           setState(() {
//             displayName = newName;
//           });
//           Utils.toastMessage('Display name updated successfully.');
//         }).catchError((error) {
//           // Handle any error that occurs during the display name update
//           Utils.toastMessage('Error updating display name: $error');
//         });
//       }
//     }
//
//     Future<void> _showEditDisplayNameDialog() async {
//       String newName = displayName;
//
//       await showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text('Edit Display Name'),
//             content: TextFormField(
//               initialValue: displayName,
//               onChanged: (value) {
//                 newName = value;
//               },
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   // Update the display name in Firebase
//                   _updateDisplayNameFirebase(newName);
//                   Navigator.pop(context);
//                 },
//                 child: Text('Save'),
//               ),
//             ],
//           );
//         },
//       );
//     }
//     final data =  FirebaseFirestore.instance.collection("slot").where('userUid',isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
//     return Scaffold(
//       body: Column(
//         children: [
//           Container(
//             height: MediaQuery.of(context).size.height * 0.55,
//             decoration: const BoxDecoration(
//               color: Color(0xff333333),
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(60),
//                 bottomRight: Radius.circular(60),
//               ),
//             ),
//             child: Column(
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.only(top: 52),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       SizedBox(
//                         height: 20,
//                         width: 38,
//                       ),
//                       Text(
//                         'Profile',
//                         style: TextStyle(
//                           color: Color(0xffffffff),
//                           fontSize: 25,
//                           fontFamily: 'Montserrat',
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.only(right: 15),
//                         child: Icon(
//                           Icons.more_vert,
//                           color: Color(0xfffffffff),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(50),
//                       child: url
//                           ? Image.network(
//                         photoUrl,
//                         width: 100,
//                         height: 100,
//                         fit: BoxFit.cover,
//                       )
//                           : Icon(Icons.person, size: 100), // Show default icon if URL is null
//                     )
//
//                   ],
//                 ),
//                 ElevatedButton(
//                   onPressed: _changePhotoButtonPressed,
//                   child: Text('Change Photo'),
//                 ),
//                 const SizedBox(
//                   height: 13,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       displayName,
//                       style: const TextStyle(
//                         color: Color(0xffffffff),
//                         fontFamily: 'Montserrat',
//                         fontWeight: FontWeight.w600,
//                         fontSize: 20,
//                       ),
//                     ),
//                     SizedBox(width: 5),
//                     IconButton(
//                       icon: Icon(Icons.edit, color: Colors.white),
//                       onPressed: () {
//                         _showEditDisplayNameDialog(); // Show the edit display name dialog
//                       },
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 3,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       email,
//                       style: const TextStyle(
//                         color: Color(0xffffffff),
//                         fontFamily: 'Montserrat',
//                         fontWeight: FontWeight.w400,
//                         fontSize: 14,
//                       ),
//                     )
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 25,
//                 ),
//
//                 const SizedBox(
//                   height: 5,
//                 ),
//
//               ],
//             ),
//           ),
//
//
//         ],
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:image_picker/image_picker.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:studentsapp/add_notice.dart';
import 'package:studentsapp/auth_provider.dart';
import 'package:studentsapp/utils.dart';
import 'package:studentsapp/utils/app_color.dart';
import 'package:studentsapp/view/intro1_screen.dart';

class ProfileView extends StatefulWidget {
  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final auth = FirebaseAuth.instance;
  File? _image;
  String _imageUrl = '';
  bool _isLoading = false;
  String _errorMessage = '';
  CollectionReference profileRef =
      FirebaseFirestore.instance.collection("users");

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  String _displayName =
      FirebaseAuth.instance.currentUser!.displayName ?? "Student's Name";

  void _updateDisplayNameFirebase(String newName) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      user.updateDisplayName(newName).then((_) {
        setState(() {
          _displayName = newName;
        });
        Utils.toastMessage('Display name updated successfully.');
      }).catchError((Error) {
        // Handle any error that occurs during the display name update
        Utils.toastMessage('Error updating display name: $Error');
      });
    }
  }

  Future<void> _showEditDisplayNameDialog() async {
    var newName = _displayName;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColor.blackColor,
          title: const Text(
            'Edit Your Name',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              color: AppColor.whiteColor,
            ),
          ),
          content: TextFormField(
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.white),
              ),
              fillColor: const Color(0xfffffffff),
              focusColor: const Color(0xffffffff),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
            ),
            initialValue: _displayName,
            style: const TextStyle(
              color: Color(0xffffffff),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
            ),
            onChanged: (value) {
              newName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    color: AppColor.redColor,
                    fontSize: 17),
              ),
            ),
            TextButton(
              onPressed: () {
                _updateDisplayNameFirebase(newName);
                Navigator.pop(context);
              },
              child: const Text(
                'Save',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    color: AppColor.whiteColor,
                    fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'photoUrl': '',
          });
          userDoc = await _firestore.collection('users').doc(user.uid).get();
        }
        _imageUrl = userDoc.get('photoUrl') ?? '';
      } catch (error) {
        _errorMessage = 'Error fetching user profile: $error';
      }
    } else {
      _errorMessage = 'User is not authenticated';
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      // Create a Completer to handle the result of the dialog
      Completer<bool> completer = Completer<bool>();

      // Show a confirmation dialog
      Dialogs.bottomMaterialDialog(
        msg: 'Are you sure you want to log out? You can\'t undo this action.',
        msgStyle: TextStyle(
            color: AppColor.blueColor,
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w700,
            fontSize: 15),
        title: 'Logout',
        titleStyle: TextStyle(
            color: AppColor.redColor,
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w700,
            fontSize: 19),
        context: context,
        actions: [
          IconsOutlineButton(
            onPressed: () {
              completer.complete(
                  false); // Complete with 'false' when Cancel is pressed
              Navigator.of(context).pop();
            },
            text: 'Cancel',
            iconData: Icons.cancel_outlined,
            textStyle: TextStyle(color: Colors.grey),
            iconColor: Colors.grey,
          ),
          IconsButton(
            onPressed: () async {
              completer.complete(
                  true); // Complete with 'true' when Logout is pressed
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const IntroScreen1()),
                (route) => false,
              );
            },
            text: 'Logout',
            iconData: Icons.exit_to_app,
            color: Colors.blue,
            textStyle: TextStyle(color: Colors.white),
            iconColor: Colors.white,
          ),
        ],
      );

      // Wait for the user's decision
      bool result = await completer.future;

      // If the user confirms the logout, result will be true
      if (result == true) {
        // Perform the logout
        await FirebaseAuth.instance.signOut();

        // Navigate to the CreateAccountPage and remove all previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const IntroScreen1()),
          (route) => false,
        );
      }
    } catch (error) {
      print('Error signing out: $error');
    }
  }

  Future<void> _uploadImage() async {
    try {
      final picker = ImagePicker();
      XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Use image cropper
        ImageCropper imageCropper = ImageCropper();
        CroppedFile? croppedFile = await imageCropper.cropImage(
          sourcePath: pickedFile.path,
        );

        if (croppedFile != null) {
          // Convert CroppedFile to File
          _image = File(croppedFile.path);

          setState(() {
            _isLoading = true;
            _errorMessage = '';
          });

          String uid = _auth.currentUser!.uid;
          Reference storageReference =
              _storage.ref().child('user_photos/$uid.jpg');
          UploadTask uploadTask = storageReference.putFile(_image!);

          await uploadTask.whenComplete(() async {
            String url = await storageReference.getDownloadURL();

            // Update the image URL in Firestore
            await _firestore
                .collection('users')
                .doc(uid)
                .update({'photoUrl': url});

            await Auth_Provider().updateUserProfileImageUrl(url);

            setState(() {
              _imageUrl = url;
              _isLoading = false;
            });
          });
        } else {}
      }
    } catch (error) {
      _errorMessage = 'Error uploading image: $error';
      print('Error: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool refreshing = false;

  // Simulating some data fetching
  Future<void> _refreshData() async {
    setState(() {
      refreshing = true;
    });

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      refreshing = false;
    });
  }

  Future<String?> _showPasswordPrompt(BuildContext context) async {
    String? enteredPassword;

    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                autofocus: true, // Automatically focuses on the text field
                obscureText: true,
                onChanged: (value) {
                  enteredPassword = value;
                },
                onSubmitted: (value) {
                  _submitPassword(context, enteredPassword);
                },
                decoration: InputDecoration(hintText: 'Password'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _submitPassword(context, enteredPassword);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }
  
  void _submitPassword(BuildContext context, String? enteredPassword) {
    if (enteredPassword == 'abhi') {
      // Replace current route with DashboardScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AddNoticePage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incorrect password. Please try again.'),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    // final themeProvider = Provider.of<ThemeProvider>(context);
    User? user = _auth.currentUser;
    // bool isDarkMode = themeProvider.isDarkMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: Scaffold(
          body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       IconButton(
                //         icon: const Icon(
                //           Icons.arrow_back,
                //           color: ,
                //           size: 33,
                //         ),
                //         onPressed: () {
                //           Navigator.pop(context);
                //         },
                //       ),
                //     ],
                //   ),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(80),
                              border: Border.all(
                                color:  Colors.purple.shade200,
                                width: 1.2,
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.purple,
                                  )
                                : _errorMessage.isNotEmpty
                                    ? Center(
                                        child: Text(
                                          _errorMessage,
                                          style: const TextStyle(
                                              color: Colors.purple),
                                        ),
                                      )
                                    : CircleAvatar(
                                        radius: 80,
                                        backgroundImage: (_image != null)
                                            ? FileImage(_image!)
                                            : (_imageUrl.isNotEmpty)
                                                ? NetworkImage(_imageUrl)
                                                : Image.asset(
                                                        "assets/edit_imageicon.png")
                                                    as ImageProvider,
                                      ),
                          ),
                        ),
                        Positioned(
                          right: 3,
                          bottom: 8,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color:  Colors.purple.shade400,
                                  width: 1.0,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: InkWell(
                                  onTap: _uploadImage,
                                  child: Image.asset(
                                    "assets/edit_imageicon.png",
                                    width: 27,
                                    height: 27,
                                    color:  Colors.purple.shade200,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 45),
                    Text(
                      _displayName,
                      style: TextStyle(
                          color: Colors.grey.shade700,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w700,
                          fontSize: 19),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.purple,
                        size: 22,
                      ),
                      onPressed: _showEditDisplayNameDialog,
                    ),
                  ],
                ),

// Check if the user's email is not available
                if (user?.email == null)
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid) // Assuming user is not null here
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // While fetching email, show a loading indicator
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        // If an error occurs, show an error message
                        return Text('Error: ${snapshot.error}');
                      } else {
                        // If email is fetched successfully, display it
                        final userEmail =
                            snapshot.data?.get('email') ?? 'Email not found';
                        return Text(
                          userEmail,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      }
                    },
                  ),

                const SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      const Divider(color:  Colors.purple),
                      ListTile(
                        title: Text(
                          'Admin',
                          style: TextStyle(
                              color: Colors.purple.shade400,
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w700,
                              fontSize: 19),
                        ),
                        onTap: () async{
                            String? enteredPassword =
                                await _showPasswordPrompt(context);
                            if (enteredPassword == "abhi") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddNoticePage()),
                              );
                            } else if (enteredPassword != null) {
                              // Check if password prompt was dismissed (not null)
                              // Display an error message for incorrect password
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 5.0,
                                          spreadRadius: 2.0,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Incorrect password. Please try again.',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                        },
                      ),
                      // const Divider(color: Color(0xffaf420b)),
                    
                      const Divider(color:  Colors.purple),
                      ListTile(
                        title: Text(
                          'Invite a Friend',
                          style: TextStyle(
                              color:  Colors.purple.shade400,
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w700,
                              fontSize: 19),
                        ),
                        onTap: () async {
                          // Show a loading indicator while fetching data
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Center(child: CircularProgressIndicator());
                            },
                          );

                          try {
                            // Fetch the referral code from Firebase
                            QuerySnapshot querySnapshot = await profileRef
                                .where("refCode",
                                    isEqualTo: auth.currentUser!.uid)
                                .get();
                            if (querySnapshot.docs.isNotEmpty) {

                              // Share the referral code
                                String shareMessage =
                                ("Hey! I've been using this amazing student app to stay organized and manage my academic life more efficiently. It's been a game-changer for me, so I thought I'd share it with you. Check it out and see how it can help you too!");
                              Share.share(shareMessage);
                            } else {
                              // Handle case where referral code is not found
                              Utils.toastMessage('Referral code not found.');
                            }
                          } catch (e) {
                            // Handle error while fetching data
                            Utils.toastMessage(
                                'Error fetching referral code: $e');
                          } finally {
                            // Dismiss the loading indicator
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      const Divider(color:Colors.purple),
                      ListTile(
                          title: Text(
                            'Logout',
                            style: TextStyle(
                                color:  Colors.purple.shade400,
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.w700,
                                fontSize: 19),
                          ),
                          onTap: () {
                            _signOut(context);
                          }),
                      const Divider(color: Colors.purple),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
