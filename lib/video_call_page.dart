import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'socket_io.dart';

class VideoCallPage extends StatefulWidget {
  final String userName;
  final String roomName;
  final bool isHost;

  const VideoCallPage({super.key, required this.userName, required this.roomName, required this.isHost});

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final Signaling signaling = Signaling();
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final Map<String, RTCVideoRenderer> remoteRenderers = {};

  bool micOn = true;
  bool camOn = true;

  @override
  void initState() {
    super.initState();
    initRenderers();
    initSignaling();
  }

  Future<void> initRenderers() async {
    await localRenderer.initialize();
  }

  Future<void> initSignaling() async {
    signaling.connect('http://192.168.1.114:3000');

    signaling.socket.on('connect', (_) async {
      print("✅ Connected to signaling server: ${signaling.socket.id}");

      await signaling.initLocalStream();
      setState(() {
        localRenderer.srcObject = signaling.localStream;
      });

      if (widget.isHost) {
        signaling.createRoom(widget.roomName, widget.userName);
      } else {
        signaling.joinRoom(widget.roomName, widget.userName);
      }
    });

    signaling.onAddRemoteStream = (stream, peerId) async {
      final renderer = RTCVideoRenderer();
      await renderer.initialize();
      renderer.srcObject = stream;
      setState(() {
        remoteRenderers[peerId] = renderer;
      });
      print("📹 Remote stream added: $peerId");
    };
  }

  @override
  void dispose() {
    localRenderer.dispose();
    remoteRenderers.forEach((key, renderer) => renderer.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    RTCVideoRenderer? remoteRenderer;
    if (remoteRenderers.isNotEmpty) {
      remoteRenderer = remoteRenderers.values.first;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Room: ${widget.roomName}"), backgroundColor: Colors.black),
      body: Stack(
        children: [
          /// Remote video full screen
          Positioned.fill(
            child: remoteRenderer != null
                ? RTCVideoView(remoteRenderer)
                : const Center(
                    child: Text("Waiting for other user...", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
          ),

          /// Local video small preview
          Positioned(
            right: 16,
            top: 16,
            width: 120,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                // border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: RTCVideoView(localRenderer, mirror: true),
            ),
          ),

          /// Bottom controls
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mute button
                CircleAvatar(
                  backgroundColor: micOn ? Colors.green : Colors.red,
                  radius: 28,
                  child: IconButton(
                    icon: Icon(micOn ? Icons.mic : Icons.mic_off, color: Colors.white),
                    onPressed: () {
                      setState(() => micOn = !micOn);
                      signaling.localStream?.getAudioTracks().first.enabled = micOn;
                    },
                  ),
                ),
                const SizedBox(width: 20),

                // End call button
                CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 32,
                  child: IconButton(
                    icon: const Icon(Icons.call_end, color: Colors.white),
                    onPressed: () async {
                      await signaling.leaveRoom(roomId: widget.roomName, username: widget.userName);

                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 20),

                // Switch camera button
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 28,
                  child: IconButton(
                    icon: const Icon(Icons.cameraswitch, color: Colors.white),
                    onPressed: () {
                      signaling.localStream?.getVideoTracks().first.switchCamera();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
