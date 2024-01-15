import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _textController = TextEditingController();
  List<String> messages = [];

  Widget buildMessage(String message) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void sendMessage(String message) {
    setState(() {
      messages.add(message);
      _textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return buildMessage(messages[index]);
                },
              ),
            ),
            Container(
              color: Colors.grey[200],
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 50,
                    child: IconButton(
                      icon: Icon(Icons.attach_file),
                      onPressed: () {
                        // Acción cuando se presiona el icono al principio
                        // Puedes agregar tu lógica aquí
                      },
                    ),
                  ),
                  Container(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      minLines: 1,
                      maxLines:
                          5, // Ajusta el número máximo de líneas según tus necesidades
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      onEditingComplete: () {
                        // Acción cuando se presiona el botón "Hecho" en el teclado
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Mensaje...',
                      ),
                    ),
                  ),
                  Container(
                    width: 10,
                  ),
                  SizedBox(
                    width: 50,
                    child: IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        sendMessage(_textController.text);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
