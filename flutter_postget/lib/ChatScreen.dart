import 'dart:io';

import 'package:file_picker/file_picker.dart';
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
  late AppData appData;
  String currentMessage = ''; // Mensaje actualizado gradualmente

  @override
  void initState() {
    super.initState();
    appData = AppData();
    appData.textStream.listen((texto) {
      setState(() {
        currentMessage = texto;
      });
    });

    // Llama automáticamente a sendAndReceive después de un breve retraso
    Future.delayed(Duration(milliseconds: 500), () {
      sendAndReceive();
    });
  }

  void sendMessage(String message) {
    setState(() {
      appData.sendMessage(message);
      _textController.clear();
    });
  }

  Future<void> sendAndReceive() async {
    final message = _textController.text;
    if (message.isNotEmpty) {
      sendMessage(message);

      // Enviar mensaje al servidor y recibir la respuesta
      await appData.enviarJSON(message);

      // Agregar la respuesta del servidor a messages si no es nula
      if (appData.dataPost != null) {
        appData.respueta(appData.dataPost);
      }
    }
  }

  Future<void> sendImageAndReceive() async {
    try {
      // Utiliza el método `pickFiles` de FilePicker para seleccionar un archivo
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        File file = File(result.files.single.path!);

        // Enviar imagen al servidor y recibir la respuesta
        String response = await appData.loadHttpPostByChunks(
            'http://localhost:3000/data', file);

        // Agregar la respuesta del servidor a messages si no es nula
        if (response.isNotEmpty) {
          appData.respueta(response);
        }
      }
    } catch (e) {
      print('Error al enviar y recibir la imagen: $e');
    }
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
                itemCount: appData.messages.length,
                itemBuilder: (context, index) {
                  return buildMessage(appData.messages[index]);
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
                        sendImageAndReceive();
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
                      maxLines: 5,
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
                        sendAndReceive();
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

  Widget buildMessage(String message) {
    bool isSent = appData.messages.indexOf(message) % 2 ==
        0; // Cambiar según tus necesidades
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
}
