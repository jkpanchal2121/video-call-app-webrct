import 'package:demoproject/Bloc/AuthBloc/auth_bloc.dart';
import 'package:demoproject/Screens/AuthScreen/login_screen.dart';
import 'package:demoproject/Service/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/constent.dart';
import '../AudioVideoCallScreen/audio_call.dart';

class User {
  final String name;
  final String email;
  final String role;
  final String avatarUrl; // optional network image

  User({
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl = '',
  });
}

class UserListScreen extends StatelessWidget {
  UserListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Gradient AppBar
          Container(
            padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Users',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return InkWell(
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            prefs.remove('accessToken');
                            prefs.remove('email');
                            prefs.remove('userName');

                            accessToken = null;
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          child: Icon(Icons.logout, color: Colors.black),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'All registered users',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),

          BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              // TODO: implement listener
            },
            builder: (context, state) {
              return
                Expanded(
                child: RefreshIndicator.adaptive(
                  color: Colors.blue,
                  onRefresh: () async {
                    context.read<AuthBloc>().add(GetUserListEvent());
                  },
                  child:
                  ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: state.userListModelData?.data?.length,
                    itemBuilder: (context, index) {
                      final user = state.userListModelData?.data?[index];

                      return InkWell(
                        onTap: () {
                          // Tap on whole user card
                          // For example: Navigate to a user detail screen
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => UserDetailScreen(user: user),
                          //   ),
                          // );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          color: Colors.lightBlue[50],
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Avatar
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: user?.avatar?.isNotEmpty ?? false
                                      ? NetworkImage(user?.avatar ?? '')
                                      : null,
                                  backgroundColor: Colors.blueAccent,
                                  child: user?.avatar?.isEmpty ?? false
                                      ? Text(
                                    user?.username?[0] ?? '',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                                  )
                                      : null,
                                ),
                                SizedBox(width: 16),

                                // User details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user?.username ?? '',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        user?.email ?? '',
                                        style: TextStyle(color: Colors.grey[700]),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        user?.online.toString() ?? '',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Audio and Video Call Actions
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.phone, color: Colors.green, size: 28),
                                      onPressed: () {
                                        // 🔊 Start audio call
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CallScreen(
                                              roomId: user?.sId ?? '', // pass user id as room
                                              isAudio: true,
                                              socketService: SocketService(),
                                              username: user?.username ?? '',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.videocam,
                                          color: Colors.blueAccent, size: 28),
                                      onPressed: () {
                                        // 🎥 Start video call
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CallScreen(
                                              roomId: user?.sId ?? '', // pass user id as room
                                              isAudio: false,
                                              socketService: SocketService(),
                                              username: user?.username ?? '',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )

                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
