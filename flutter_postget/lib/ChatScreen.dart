import 'package:flutter/material.dart';
import 'app_data.dart'; // Asegúrate de importar la clase AppData

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _textController = TextEditingController();
  List<String> messages = [];
  late AppData appData;

  @override
  void initState() {
    super.initState();
    appData = AppData();
  }

  Widget buildMessage(String message, bool isSent) {
    return Row(
      mainAxisAlignment:
          isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Container(
            margin: EdgeInsets.all(4),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSent ? Colors.blue : Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void sendMessage(String message) {
    setState(() {
      appData.sendMessage(message);
      messages = appData.messages;
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
                  bool isSent =
                      index % 2 == 0; // Alternar entre sent y received
                  return buildMessage(messages[index], isSent);
                },
              ),
            ),
            Container(
              color: Colors.grey[200],
              padding: EdgeInsets.all(4.0),
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
                    width: 60,
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
