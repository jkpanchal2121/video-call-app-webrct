import 'package:flutter/material.dart';

import 'host_screen.dart';
import 'join_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _urlController = TextEditingController(
    text: "http://localhost:3000", // default URL (you can change)
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("WebRTC Rooms")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TextField for server URL
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: "Signaling Server URL",
                  hintText: "Enter server URL (e.g. http://192.168.1.100:3000)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Host button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HostPage(serverUrl: _urlController.text),
                    ),
                  );
                },
                child: const Text("I’m Host (Create Room)"),
              ),
              const SizedBox(height: 20),

              // Guest button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JoinPage(serverUrl: _urlController.text),
                    ),
                  );
                },
                child: const Text("I’m Guest (Join Room)"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
