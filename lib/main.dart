import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat bot',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Chatbot'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final _controller = TextEditingController();
  final channel = WebSocketChannel.connect(
    Uri.parse('wss://echo.websocket.events'),
  );

  String _aiResponse = '';

  // void _sendMessage() {
  //   if (_controller.text.isNotEmpty) {
  //     channel.sink.add(_controller.text);
  //     _controller.clear();
  //   }
  // }

  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final userMessage = _controller.text;
      _controller.clear();
      setState(() {
        _aiResponse = 'Thinking';
      });

      final response = await getApiResponse(userMessage);

      setState(() {
        _aiResponse = response;
      });
    }
  }


  Future<String> getApiResponse (String message) async{
     final url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

     final headers =
     {
       'Content-Type': 'application/json',
       'X-goog-api-key': "AIzaSyD7O_uNoyDJxNDw2vZmM6--2M2Q4qwdhQE",
     };

     final body = jsonEncode({
       "contents" :[
         {
           "parts" : [
             {
               "text" : _controller.text,
             }
           ]
         }
       ]
     });


     try{
       final response = await http.post(
         Uri.parse(url),
         headers: headers,
         body: body,
       );
       if(response.statusCode == 200){
         final jsonResponse = jsonDecode(response.body);
         print('josnresponse is ${jsonResponse}');
         return jsonResponse['candidates'][0]['content']['parts'][0]['text'];
       }else {
         // Handle different status codes.
         print('Failed with status code: ${response.statusCode}');
         print('Response body: ${response.body}');
         return 'Error: Failed to get a response from the API.';
       }

     }catch(e){
// Handle any network or other errors.
       print('Error sending request: $e');
       return 'Error: An error occurred.';
     }
  }

  @override
  void dispose() {
    channel.sink.close();
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextField(controller: _controller),
                SizedBox(height: 10),
                ElevatedButton(onPressed:  _sendMessage, child: Text('Send')),
                const SizedBox(height: 20),

                Text(
                  _aiResponse.isNotEmpty ? "AI Response : $_aiResponse" : 'Enter a message and press "Send"',
                  style: const TextStyle(fontSize: 16),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
