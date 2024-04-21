import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:studentsapp/add_notice.dart';
import 'package:studentsapp/profile.dart';
import 'package:studentsapp/share.dart';
import 'package:studentsapp/utils/app_color.dart';

import 'package:studentsapp/utils/constant_color.dart';
import 'package:studentsapp/view/home_sc.dart';
import 'package:studentsapp/view/signup_screen.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
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
                MaterialPageRoute(builder: (context) => SignUpScreen()),
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
          MaterialPageRoute(builder: (context) => SignUpScreen()),
          (route) => false,
        );
      }
    } catch (error) {
      print('Error signing out: $error');
    }
  }
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    // AddNoticePage(),
    ShowNoticesPage(),
    ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColor.primaryScreenBackgroundColor,
    
      // drawer: Drawer(
      //   child: ListView(
      //     children: [
      //       DrawerHeader(
      //         child: Text(
      //           "Menu",
      //           style: TextStyle(fontSize: 24, color: Colors.white),
      //         ),
      //         decoration: BoxDecoration(
      //           color: Colors.blue,
      //         ),
      //       ),
      //       ListTile(
      //         title: Text("Show Review"),
      //         onTap: () {},
      //       ),
      //       ListTile(
      //         title: Text("Add Review"),
      //         onTap: () {
      //           Navigator.pushAndRemoveUntil(
      //             context,
      //             MaterialPageRoute(builder: (context) => AddNoticePage()),
      //             (route) => false,
      //           );
      //           // Handle tap for "Add Review" option
      //         },
      //       ),
      //       ListTile(
      //         title: Text("All"),
      //         onTap: () {
      //           // Handle tap for "All" option
      //         },
      //       ),
      //       ListTile(
      //         title: Text("Option 4"), // Replace with your option title
      //         onTap: () {
      //           // Handle tap for "Option 4" option
      //         },
      //       ),
      //       ListTile(
      //         title: Text("Option 5"), // Replace with your option title
      //         onTap: () {
      //           // Handle tap for "Option 5" option
      //         },
      //       ),
      //     ],
      //   ),
      // ),
       appBar: AppBar(
        title: Text(
          "STUDENT'S UNION",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
     

          body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.add),
          //   label: 'Add Notice',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Show Notices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
      // Column(children: [
      //   ////// ///// top widgets
      //   Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      //     child: Expanded(
      //       child: Row(
      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //         children: [
      //           /////// //// left top Picture Hamburger Image

      //           Image.asset(
      //             "assets/homePageImage/Hamburger Menu.png",
      //             width: 40,
      //             height: 40,
      //           ),
      //           ////// ///// HomePage Text
      //           Text(
      //             "HomePage ",
      //             style: TextStyle(
      //                 fontFamily: "Manrope",
      //                 fontSize: 18,
      //                 color: ConstantColor.textColor,
      //                 fontWeight: FontWeight.w700),
      //           ),
      //           /////// //// left top Picture Hamburger Image
      //           IconButton(
      //               onPressed: () {
      //                 Navigator.pushAndRemoveUntil(
      //                   context,
      //                   MaterialPageRoute(builder: (context) => AboutPage()),
      //                   (route) => false,
      //                 );
      //               },
      //               icon: Icon(Icons.share)),
      //           IconButton(
      //               onPressed: () {
      //                 _signOut(context);
      //               },
      //               icon: Icon(
      //                 Icons.logout_rounded,
      //                 color: AppColor.blueColor,
      //               ))
      //         ],
      //       ),
      //     ),
      //   )
      // ]),
    );
  }
}
