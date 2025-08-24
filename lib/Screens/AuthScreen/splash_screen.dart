import 'package:demoproject/Bloc/AuthBloc/auth_bloc.dart';
import 'package:demoproject/Network/api_client.dart';
import 'package:demoproject/Network/repository.dart';
import 'package:demoproject/Screens/HomeScreen/all_user_list_screen.dart';
import 'package:demoproject/Utils/constent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'login_screen.dart'; // Import your login screen here
import 'package:equatable/equatable.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    authCheck();
    // Navigate to LoginScreen after 3 seconds
  }

  authCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    accessToken = prefs.getString('accessToken');
    // Navigate to LoginScreen after 3 seconds
    Timer(Duration(seconds: 3), () {
      if (accessToken != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (context) => AuthBloc(Repository.getInstance())..add(GetUserListEvent()),
              child: UserListScreen(),
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (context) => AuthBloc(Repository.getInstance()),
              child: LoginScreen(),
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF42A5F5),
              Color(0xFF1E88E5),
            ], // Two-color combination
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _animation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.video_call,
                    size: 60,
                    color: Color(0xFF1E88E5),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'My Video App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Connect. Call. Enjoy.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
