import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect(String baseUrl) {
    socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Connected to socket: ${socket.id}');
    });

    socket.onDisconnect((_) {
      print('Disconnected');
    });
  }

  void createRoom(String roomId, String username) {
    socket.emit('create-room', {'roomId': roomId, 'username': username});
  }

  void joinRoom(String roomId, String username) {
    socket.emit('join-room', {'roomId': roomId, 'username': username});
  }

  void sendOffer(String to, dynamic offer) {
    socket.emit('offer', {'to': to, 'offer': offer});
  }

  void sendAnswer(String to, dynamic answer) {
    socket.emit('answer', {'to': to, 'answer': answer});
  }

  void sendCandidate(String to, dynamic candidate) {
    socket.emit('candidate', {'to': to, 'candidate': candidate});
  }

  // Listen to events
  void on(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }
}
