import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../Service/socket_service.dart';

class CallScreen extends StatefulWidget {
  final String roomId;
  final bool isAudio; // true = audio call, false = video call
  final SocketService socketService;
  final String username;

  const CallScreen({
    super.key,
    required this.roomId,
    required this.isAudio,
    required this.socketService,
    required this.username,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late RTCPeerConnection _peerConnection;
  late MediaStream _localStream;

  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final List<RTCVideoRenderer> _remoteRenderers = [];

  bool _micEnabled = true;
  bool _cameraEnabled = true;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _initCall();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
  }

  Future<void> _initCall() async {
    // 1️⃣ Local stream
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': widget.isAudio
          ? false
          : {
        'facingMode': 'user',
        'width': 640,
        'height': 480,
      },
    });
    _localRenderer.srcObject = _localStream;

    // 2️⃣ Peer connection
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    });

    _localStream.getTracks().forEach((t) => _peerConnection.addTrack(t, _localStream));

    // 3️⃣ Remote track handler
    _peerConnection.onTrack = (event) async {
      if (event.streams.isNotEmpty) {
        final renderer = RTCVideoRenderer();
        await renderer.initialize();
        renderer.srcObject = event.streams[0];
        setState(() => _remoteRenderers.add(renderer));
      }
    };

    // 4️⃣ ICE candidate
    _peerConnection.onIceCandidate = (c) {
      if (c != null) widget.socketService.sendCandidate(widget.roomId, c.toMap());
    };

    // 5️⃣ Socket signaling
    widget.socketService.on('offer', (data) async {
      await _peerConnection.setRemoteDescription(
        RTCSessionDescription(data['offer']['sdp'], data['offer']['type']),
      );
      final answer = await _peerConnection.createAnswer();
      await _peerConnection.setLocalDescription(answer);
      widget.socketService.sendAnswer(data['from'], answer.toMap());
    });

    widget.socketService.on('answer', (data) async {
      await _peerConnection.setRemoteDescription(
        RTCSessionDescription(data['answer']['sdp'], data['answer']['type']),
      );
    });

    widget.socketService.on('candidate', (data) async {
      final c = RTCIceCandidate(
        data['candidate']['candidate'],
        data['candidate']['sdpMid'],
        data['candidate']['sdpMLineIndex'],
      );
      await _peerConnection.addCandidate(c);
    });

    // 6️⃣ Join room
    widget.socketService.joinRoom(widget.roomId, widget.username);
  }

  void _toggleMic() {
    setState(() {
      _micEnabled = !_micEnabled;
      _localStream.getAudioTracks().forEach((t) => t.enabled = _micEnabled);
    });
  }

  void _toggleCamera() {
    if (widget.isAudio) return;
    setState(() {
      _cameraEnabled = !_cameraEnabled;
      _localStream.getVideoTracks().forEach((t) => t.enabled = _cameraEnabled);
    });
  }

  Future<void> _switchCamera() async {
    if (widget.isAudio) return;
    for (var t in _localStream.getVideoTracks()) {
      await Helper.switchCamera(t);
    }
  }

  void _endCall() async {
    await _peerConnection.close();
    await _localStream.dispose();
    _localRenderer.dispose();
    for (var r in _remoteRenderers) {
      r.dispose();
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _endCall();
    super.dispose();
  }

  Widget _buildVideoGrid() {
    final allRenderers = [_localRenderer, ..._remoteRenderers];
    final count = allRenderers.length;

    return GridView.builder(
      itemCount: count,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count <= 2 ? 1 : 2,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, i) {
        return Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: RTCVideoView(
            allRenderers[i],
            mirror: i == 0,
          ),
        );
      },
    );
  }

  Widget _buildAudioUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.blueAccent,
            child: Text(
              widget.username[0].toUpperCase(),
              style: const TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.username,
            style: const TextStyle(fontSize: 22, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            "Audio Call in progress...",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              heroTag: "mic",
              backgroundColor: Colors.white,
              onPressed: _toggleMic,
              child: Icon(
                _micEnabled ? Icons.mic : Icons.mic_off,
                color: Colors.black,
              ),
            ),
            if (!widget.isAudio)
              FloatingActionButton(
                heroTag: "cam",
                backgroundColor: Colors.white,
                onPressed: _toggleCamera,
                child: Icon(
                  _cameraEnabled ? Icons.videocam : Icons.videocam_off,
                  color: Colors.black,
                ),
              ),
            if (!widget.isAudio)
              FloatingActionButton(
                heroTag: "switch",
                backgroundColor: Colors.white,
                onPressed: _switchCamera,
                child: const Icon(Icons.cameraswitch, color: Colors.black),
              ),
            FloatingActionButton(
              heroTag: "end",
              backgroundColor: Colors.red,
              onPressed: _endCall,
              child: const Icon(Icons.call_end),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: widget.isAudio ? _buildAudioUI() : _buildVideoGrid(),
            ),
            _buildControls(),
          ],
        ),
      ),
    );
  }
}
