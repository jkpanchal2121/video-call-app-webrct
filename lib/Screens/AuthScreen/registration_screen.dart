import 'package:demoproject/Bloc/AuthBloc/auth_bloc.dart';
import 'package:demoproject/Network/repository.dart';
import 'package:demoproject/Utils/constent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/theme_helper.dart';
import '../HomeScreen/all_user_list_screen.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blueAccent,
                      child: Icon(
                        Icons.person_add,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Register to get started',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    SizedBox(height: 32),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.blueAccent,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: BlocConsumer<AuthBloc, AuthState>(
                        listener: (context, state) async {
                          print(
                            'state.regStatus == RequestStatus.success>>>>${state.regStatus == RequestStatus.success}',
                          );

                          if (state.regStatus == RequestStatus.success) {
                            print(
                              'state.regStatus == RequestStatus.success>>>>${state.regStatus == RequestStatus.success}',
                            );
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            await prefs.setString(
                              'accessToken',
                              state.registrationModelData?.token ?? '',
                            );
                            await prefs.setString(
                              'userName',
                              state.registrationModelData?.username ?? '',
                            );
                            await prefs.setString(
                              'email',
                              state.registrationModelData?.email ?? '',
                            );

                            accessToken = state.registrationModelData?.token;

                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) =>
                                      AuthBloc(Repository.getInstance())
                                        ..add(GetUserListEvent()),
                                  child: UserListScreen(),
                                ),
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: () {
                              if (_emailController.text.isEmpty) {
                                ThemeHelper.showCustomSnackBar(
                                  context,
                                  message: 'Enter your email.',
                                  type: SnackBarType.error,
                                );
                              } else if (_usernameController.text.isEmpty) {
                                ThemeHelper.showCustomSnackBar(
                                  context,
                                  message: 'Enter your user name.',
                                  type: SnackBarType.error,
                                );
                              } else if (_passwordController.text.isEmpty) {
                                ThemeHelper.showCustomSnackBar(
                                  context,
                                  message: 'Enter your email.',
                                  type: SnackBarType.error,
                                );
                              } else {
                                Map<String, dynamic> regBody = {};
                                regBody['email'] = _emailController.text;
                                regBody['username'] = _usernameController.text;
                                regBody['password'] = _passwordController.text;
                                context.read<AuthBloc>().add(
                                  RegistrationEvent(regBody),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: Color(0xFF1E88E5),
                              elevation: 6,
                            ),
                            child: state.regStatus == RequestStatus.loading
                                ? SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 0.9,
                                    ),
                                  )
                                : Text(
                                    'Register',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Color(0xFF1E88E5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Implement registration with Google
                      },
                      icon: Icon(Icons.login, color: Colors.redAccent),
                      label: Text(
                        'Register with Google',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
