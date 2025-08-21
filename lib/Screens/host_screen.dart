import 'package:flutter/material.dart';

import '../video_call_page.dart';

class HostPage extends StatefulWidget {
  final String serverUrl;

  const HostPage({super.key,required this.serverUrl});

  @override
  State<HostPage> createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> {
  final TextEditingController roomController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Room")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: roomController,
              decoration: const InputDecoration(
                labelText: "Room Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (roomController.text.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoCallPage(
                        userName: "Host",
                        serverUrl: widget.serverUrl,
                        roomName: roomController.text.trim(),
                        isHost: true,
                      ),
                    ),
                  );
                }
              },
              child: const Text("Create Room"),
            ),
          ],
        ),
      ),
    );
  }
}
