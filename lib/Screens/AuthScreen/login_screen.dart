import 'package:demoproject/Bloc/AuthBloc/auth_bloc.dart';
import 'package:demoproject/Network/api_client.dart';
import 'package:demoproject/Network/repository.dart';
import 'package:demoproject/Screens/AuthScreen/registration_screen.dart';
import 'package:demoproject/Screens/HomeScreen/all_user_list_screen.dart';
import 'package:demoproject/Utils/theme_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/constent.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key});

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
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Login to continue',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    SizedBox(height: 32),
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
                    BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) async {
                        print(
                          '>>>login::${state.loginStatus == RequestStatus.success}',
                        );
                        if (state.loginStatus == RequestStatus.success) {
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

                          // Show snackbar
                          ThemeHelper.showCustomSnackBar(
                            context, // Use navigatorKey context
                            message: 'Logged in successfully.',
                            type: SnackBarType.success,
                          );

                          // ✅ Navigate after current frame

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
                        } else if (state.loginStatus == RequestStatus.failure) {
                          ThemeHelper.showCustomSnackBar(
                            context,
                            message: state.errorMessage ?? '',
                            type: SnackBarType.error,
                          );
                        }
                      },
                      builder: (context, state) {
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              _emailController.text =
                                  'jaypanchal2120@gmail.com';
                              _passwordController.text = 'jay@2102';
                              if (_emailController.text.isEmpty) {
                                ThemeHelper.showCustomSnackBar(
                                  context,
                                  message: 'Enter your email.',
                                  type: SnackBarType.error,
                                );
                              } else if (_passwordController.text.isEmpty) {
                                ThemeHelper.showCustomSnackBar(
                                  context,
                                  message: 'Enter your password.',
                                  type: SnackBarType.error,
                                );
                              } else {
                                Map<String, dynamic> loginBody = {};
                                loginBody['email'] = _emailController.text;
                                loginBody['password'] =
                                    _passwordController.text;
                                context.read<AuthBloc>().add(
                                  LoginEvent({
                                    "email": "jaypanchal2120@gmail.com",
                                    "password": "jay@2102",
                                  }),
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
                            child: state.loginStatus == RequestStatus.loading
                                ? SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 0.9,
                                    ),
                                  )
                                : Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: TextStyle(color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) =>
                                    AuthBloc(Repository(ApiClient())),
                                child: RegisterScreen(),
                              ),
                            ),
                          ),
                          child: Text(
                            'Register',
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
                        // TODO: Implement login with Google
                      },
                      icon: Icon(Icons.login, color: Colors.black54),
                      label: Text(
                        'Login with Google',
                        style: TextStyle(color: Colors.black54),
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
