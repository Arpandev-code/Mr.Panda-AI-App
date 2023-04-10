import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatGPTApp extends StatefulWidget {
  const ChatGPTApp({Key? key}) : super(key: key);

  @override
  _ChatGPTAppState createState() => _ChatGPTAppState();
}

class _ChatGPTAppState extends State<ChatGPTApp> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _messages = [];

  Future<String> _getChatResponse(String message) async {
    const String apiKey = 'YOUR API KEY';
    const String apiUrl =
        'https://api.openai.com/v1/engines/text-davinci-003/completions';

    final Map<String, dynamic> body = {
      'prompt': 'Conversation with ChatGPT:\n' + message,
      'temperature': 0.7,
      'max_tokens': 100,
      'top_p': 1,
      'frequency_penalty': 0,
      'presence_penalty': 0
    };

    final response = await http.post(Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey'
        },
        body: json.encode(body));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final String chatResponse = data['choices'][0]['text'];
      return chatResponse.trim();
    } else {
      throw Exception('Failed to load response');
    }
  }

  void _handleSubmit(String text) async {
    _textController.clear();
    setState(() {
      _messages.insert(0, text);
    });

    final response = await _getChatResponse(text);
    setState(() {
      _messages.insert(0, response);
    });
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmit,
              decoration:
                  const InputDecoration.collapsed(hintText: "Send a message"),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _handleSubmit(_textController.text),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ChatGPT"),
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => _buildMessage(_messages[index]),
              itemCount: _messages.length,
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String message) {
    return ListTile(
      title: Text(message),
    );
  }
}
