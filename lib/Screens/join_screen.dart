import 'package:flutter/material.dart';

import '../video_call_page.dart';

class JoinPage extends StatefulWidget {
  final String serverUrl;

  const JoinPage({super.key, required this.serverUrl});

  @override
  State<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController roomController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Join Room")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Your Name", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: roomController,
              decoration: const InputDecoration(labelText: "Room Name (from host)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && roomController.text.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoCallPage(
                        userName: nameController.text.trim(),
                        roomName: roomController.text.trim(),
                        isHost: false,
                        serverUrl: widget.serverUrl,
                      ),
                    ),
                  );
                }
              },
              child: const Text("Join Room"),
            ),
          ],
        ),
      ),
    );
  }
}
