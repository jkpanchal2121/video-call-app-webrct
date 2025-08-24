import 'package:demoproject/Screens/home_screen.dart';
import 'package:demoproject/video_call_page.dart';
import 'package:flutter/material.dart';

import 'Screens/AuthScreen/login_screen.dart';
import 'Screens/AuthScreen/splash_screen.dart';
import 'Screens/HomeScreen/all_user_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video call demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:  SplashScreen(),
    );
  }
}


