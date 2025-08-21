// import 'package:flutter/material.dart';
// import 'video_call_page.dart';
//
// class RoomEntryPage extends StatefulWidget {
//   const RoomEntryPage({super.key});
//
//   @override
//   State<RoomEntryPage> createState() => _RoomEntryPageState();
// }
//
// class _RoomEntryPageState extends State<RoomEntryPage> {
//   final TextEditingController roomController = TextEditingController();
//   final TextEditingController nameController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Join / Create Room")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(labelText: "Your Name"),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: roomController,
//               decoration: const InputDecoration(labelText: "Room Name"),
//             ),
//             const SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   child: const Text("Create Room"),
//                   onPressed: () {
//                     if (roomController.text.isNotEmpty &&
//                         nameController.text.isNotEmpty) {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => VideoCallPage(
//                             roomId: roomController.text,
//                             username: nameController.text,
//                             isHost: true,
//                           ),
//                         ),
//                       );
//                     }
//                   },
//                 ),
//                 ElevatedButton(
//                   child: const Text("Join Room"),
//                   onPressed: () {
//                     if (roomController.text.isNotEmpty &&
//                         nameController.text.isNotEmpty) {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => VideoCallPage(
//                             roomId: roomController.text,
//                             username: nameController.text,
//                             isHost: false,
//                           ),
//                         ),
//                       );
//                     }
//                   },
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
