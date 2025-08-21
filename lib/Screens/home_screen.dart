import 'package:flutter/material.dart';

import 'host_screen.dart';
import 'join_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("WebRTC Rooms")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HostPage()),
                );
              },
              child: const Text("I’m Host (Create Room)"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const JoinPage()),
                );
              },
              child: const Text("I’m Guest (Join Room)"),
            ),
          ],
        ),
      ),
    );
  }
}