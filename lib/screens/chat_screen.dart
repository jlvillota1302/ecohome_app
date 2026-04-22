import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  IO.Socket? socket;
  List messages = [];
  final textCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    connectSocket();
  }

  Future<void> connectSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .build(),
    );

    socket!.onConnect((_) {
      debugPrint('Socket conectado');
    });

    socket!.on('messages', (data) {
      setState(() {
        messages = List.from(data);
      });
    });

    socket!.on('new-message', (msg) {
      setState(() {
        messages.add(msg);
      });
    });

    socket!.connect();
  }

  void sendMessage() {
    final text = textCtrl.text.trim();
    if (text.isEmpty) return;

    socket?.emit('new-message', {'text': text});
    textCtrl.clear();
  }

  @override
  void dispose() {
    socket?.disconnect();
    textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat EcoHome')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final msg = messages[i];
                return ListTile(
                  title: Text(msg['username'] ?? 'Usuario'),
                  subtitle: Text(msg['text'] ?? ''),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textCtrl,
                    decoration: const InputDecoration(hintText: 'Escribe un mensaje'),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}