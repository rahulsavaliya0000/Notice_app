import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:studentsapp/auth_provider.dart';
import 'package:studentsapp/firebase_options.dart';
import 'package:studentsapp/view/splash_screen.dart';

void main() async{
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FIrebaseAPI().initNotifications();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
    statusBarBrightness: Brightness.dark,
  ));
  runApp(MultiProvider(
    providers: [
      // ChangeNotifierProvider(create: (context) => RefProvider()),
      ChangeNotifierProvider(create: (context) => Auth_Provider()),
    ],
    child: MyApp(),
  ));
}

class FIrebaseAPI {
  final _firebasemessaging = FirebaseMessaging.instance;

  Future<void> initNotifications()async{
await _firebasemessaging.requestPermission();

final FCMToken = await _firebasemessaging.getToken();
print("hello gusy$FCMToken");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}


