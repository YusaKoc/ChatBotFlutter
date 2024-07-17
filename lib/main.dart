import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<String> _messages = ["Assistant: How can I help you"];
  final TextEditingController _controller = TextEditingController();

  Future<void> sendMessage(String message) async {
    setState(() {
      _messages.add("User: $message");
    });

    final response = await http.post(
      Uri.parse('YOUR IP:5005/webhooks/rest/webhook'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'sender': 'user', 'message': message}),
    );

    if (response.statusCode == 200) {
      final responses = jsonDecode(response.body) as List;
      for (var res in responses) {
        await Future.delayed(Duration(seconds: 2));
        setState(() {
          _messages.add("Assistant: ${res['text']}");
        });
      }
    } else {
      setState(() {
        _messages.add("Assistant: Failed to send message");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Assistant'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: ListTile(
                    title: Text(_messages[index]),
                    leading: Image.asset("images/robot.webp"),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final message = _controller.text;
                    _controller.clear();
                    sendMessage(message);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
