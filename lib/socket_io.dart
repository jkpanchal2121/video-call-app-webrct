import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

typedef StreamCallback = void Function(MediaStream stream, String peerId);
typedef TextCallback = void Function(String text);

class Signaling {
  late IO.Socket socket;
  MediaStream? localStream;

  // UI callbacks
  StreamCallback? onAddRemoteStream;
  TextCallback? onLog;
  TextCallback? onError;
  void Function(String roomId)? onRoomCreated;
  void Function(String roomId)? onRoomJoined;

  // State
  final Map<String, RTCPeerConnection> _peerConnections = {};
  bool _amHost = false;
  String? _hostId;

  // Connect to signaling server
  void connect(String url) {
    socket = IO.io(url, IO.OptionBuilder().setTransports(['websocket']).disableAutoConnect().enableReconnection().build());
    socket.connect();

    socket.on('connect', (_) {
      _log('✅ Connected: ${socket.id}');
    });

    socket.on('disconnect', (_) {
      _log('🔌 Disconnected');
    });

    socket.on('error', (data) {
      final msg = data is Map && data['message'] != null ? data['message'] : data.toString();
      _err('Server error: $msg');
    });

    // ===== Room lifecycle =====
    socket.on('room-created', (data) {
      final roomId = data['roomId'] as String;
      _amHost = true; // creator is the host
      _hostId = socket.id;
      _log('🟢 Room created: $roomId (I am host)');
      onRoomCreated?.call(roomId);
    });

    socket.on('room-joined', (data) async {
      final roomId = data['roomId'] as String;
      final List participants = data['participants'] as List? ?? [];
      _hostId = data['hostId'] as String?;
      _amHost = (socket.id == _hostId);

      _log('🟡 Joined room: $roomId | host: $_hostId | I am host? $_amHost | existing: ${participants.length}');
      onRoomJoined?.call(roomId);

      // Only host sends offers
      if (_amHost) {
        for (final p in participants) {
          final String peerId = p['socketId'] as String;
          if (peerId == socket.id) continue;
          await _makeOffer(peerId);
        }
      } else {
        _log('🙋 I am participant: waiting for host offers…');
      }
    });

    // Host notified when new arrives
    socket.on('new-participant', (data) async {
      final String peerId = data['participantId'] as String;
      final String username = data['username'] as String? ?? '';
      _log('👤 New participant: $username ($peerId)');
      if (_amHost) {
        await _makeOffer(peerId);
      } else {
        _log('I am not host; ignoring new-participant.');
      }
    });

    // ===== WebRTC signaling =====
    socket.on('offer', (data) async {
      final String from = data['from'];
      final offer = data['offer'];

      if (_amHost) {
        _log('⚠️ Host received an offer from $from — ignoring.');
        return;
      }

      _log('📥 Offer from $from');
      final pc = await _createPeerConnection(from);

      await pc.setRemoteDescription(RTCSessionDescription(offer['sdp'], offer['type']));

      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);

      socket.emit('answer', {
        'to': from,
        'answer': {'sdp': answer.sdp, 'type': answer.type},
      });
      _log('📤 Sent answer to $from');
    });

    socket.on('answer', (data) async {
      final String from = data['from'];
      final answer = data['answer'];
      _log('📥 Answer from $from');

      final pc = _peerConnections[from];
      if (pc != null) {
        await pc.setRemoteDescription(RTCSessionDescription(answer['sdp'], answer['type']));
      } else {
        _log('⚠️ No peerConnection for $from when answer arrived');
      }
    });

    socket.on('candidate', (data) async {
      final String from = data['from'];
      final cand = data['candidate'];
      final pc = _peerConnections[from];

      if (pc != null) {
        await pc.addCandidate(RTCIceCandidate(cand['candidate'], cand['sdpMid'], cand['sdpMLineIndex']));
      } else {
        _log('⚠️ No peerConnection for $from when candidate arrived');
      }
    });

    // ===== Someone left =====
    socket.on('participant-left', (data) {
      final peerId = data['participantId'];
      final username = data['username'] ?? '';
      _log('🚪 $username ($peerId) left the room');
      final pc = _peerConnections.remove(peerId);
      pc?.close();
    });

    socket.on('host-disconnected', (_) {
      _log('❌ Host disconnected, closing this room');
      leaveRoom();
    });
  }

  // Local media
  Future<void> initLocalStream() async {
    localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user'},
    });
    _log('🎥 Local stream ready');
  }

  // Room actions
  void createRoom(String roomId, String username) {
    if (!socket.connected) return _err('Socket not connected');
    socket.emit('create-room', {'roomId': roomId, 'username': username});
  }

  void joinRoom(String roomId, String username) {
    if (!socket.connected) return _err('Socket not connected');
    socket.emit('join-room', {'roomId': roomId, 'username': username});
  }

  Future<void> leaveRoom({String? roomId, String? username}) async {
    if (roomId != null && username != null && socket.connected) {
      socket.emit('leave-room', {'roomId': roomId, 'username': username});
    }

    for (final pc in _peerConnections.values) {
      await pc.close();
    }
    _peerConnections.clear();

    await localStream?.dispose();
    localStream = null;

    _log('👋 Left room and cleaned up peer connections');
  }

  Future<void> dispose() async {
    await leaveRoom();
    socket.dispose();
  }

  // ===== Internals =====
  Future<RTCPeerConnection> _createPeerConnection(String peerId) async {
    if (_peerConnections.containsKey(peerId)) return _peerConnections[peerId]!;

    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    final pc = await createPeerConnection(config);

    final stream = localStream;
    if (stream != null) {
      for (var track in stream.getTracks()) {
        await pc.addTrack(track, stream);
      }
    }

    pc.onIceCandidate = (candidate) {
      if (candidate != null) {
        socket.emit('candidate', {
          'to': peerId,
          'candidate': {'candidate': candidate.candidate, 'sdpMid': candidate.sdpMid, 'sdpMLineIndex': candidate.sdpMLineIndex},
        });
      }
    };

    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _log('🎬 Remote track from $peerId');
        onAddRemoteStream?.call(event.streams[0], peerId);
      }
    };

    _peerConnections[peerId] = pc;
    return pc;
  }

  Future<void> _makeOffer(String peerId) async {
    final pc = await _createPeerConnection(peerId);

    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);

    socket.emit('offer', {
      'to': peerId,
      'offer': {'sdp': offer.sdp, 'type': offer.type},
    });
    _log('📤 Sent offer to $peerId');
  }

  // Helpers
  void _log(String m) => onLog?.call(m);
  void _err(String m) {
    onError?.call(m);
    onLog?.call('❌ $m');
  }
}
