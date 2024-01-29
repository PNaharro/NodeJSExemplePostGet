import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:dio/dio.dart';

class AppData with ChangeNotifier {
  bool loadingGet = false;
  bool loadingPost = false;
  bool loadingFile = false;

  dynamic dataGet;
  dynamic dataPost;
  dynamic dataFile;

  List<String> messages = [];

  StreamController<String> _textStreamController =
      StreamController<String>.broadcast();
  Stream<String> get textStream => _textStreamController.stream;

  void enviarTextoPocoAPoco(String texto,
      {int duration = 100, int initialDelay = 0}) async {
    await Future.delayed(Duration(milliseconds: initialDelay));

    for (int i = 0; i < texto.length; i++) {
      _textStreamController.add(texto.substring(0, i + 1));
      await Future.delayed(Duration(milliseconds: duration));
    }
  }

  void sendMessage(String message) {
    messages.add(message);
    notifyListeners();
  }

  void respueta(String message) async {
    messages.add(message);
    notifyListeners();

    // Espera un breve momento antes de comenzar a enviar el texto poco a poco
    await Future.delayed(Duration(milliseconds: 500));

    // Envia el texto poco a poco
    enviarTextoPocoAPoco(message, duration: 50);
  }

  Future<void> enviarJSON(String message) async {
    final String url = 'http://localhost:3000/data';
    final Map<String, dynamic> data = {
      'type': 'test',
      'data': '{"type":"test", "mensaje":"${message}"}',
    };

    try {
      final Dio dio = Dio();
      final Response response = await dio.post(
        url,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        respueta(response.data);
      } else {
        print('Error en la solicitud: ${response.statusCode}');
      }
    } catch (error) {
      print('Error en la solicitud: $error');
    }
  }

  // Funció per fer crides tipus 'GET' i agafar la informació a mida que es va rebent
  Future<void> loadHttpGetByChunks(String url) async {
    var httpClient = HttpClient();
    var completer = Completer<void>();

    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();

      dataGet = "";

      // Listen to each chunk of data
      response.transform(utf8.decoder).listen(
        (data) {
          // Aquí rep cada un dels troços de dades que envia el servidor amb 'res.write'
          dataGet += data;
          notifyListeners();
        },
        onDone: () {
          completer.complete();
        },
        onError: (error) {
          completer.completeError(
              "Error del servidor (appData/loadHttpGetByChunks): $error");
        },
      );
    } catch (e) {
      completer.completeError("Excepció (appData/loadHttpGetByChunks): $e");
    }

    return completer.future;
  }

  // Funció per fer crides tipus 'POST' amb un arxiu adjunt,
  //i agafar la informació a mida que es va rebent
  Future<String> loadHttpPostByChunks(String url, File file) async {
    try {
      final Dio dio = Dio();
      final response = await dio.post(
        url,
        data: FormData.fromMap({
          'file': await MultipartFile.fromFile(
            file.path,
            filename: 'image.jpg',
          ),
        }),
      );

      if (response.statusCode == 200) {
        return response.data.toString();
      } else {
        print('Error en la solicitud: ${response.statusCode}');
        return 'Error en la solicitud: ${response.statusCode}';
      }
    } catch (error) {
      print('Error en la solicitud: $error');
      return 'Error en la solicitud: $error';
    }
  }

  // Funció per fer carregar dades d'un arxiu json de la carpeta 'assets'
  Future<dynamic> readJsonAsset(String filePath) async {
    // If development, wait 1 second to simulate a delay
    if (!kReleaseMode) {
      await Future.delayed(const Duration(seconds: 1));
    }

    try {
      var jsonString = await rootBundle.loadString(filePath);
      final jsonData = json.decode(jsonString);
      return jsonData;
    } catch (e) {
      throw Exception("Excepció (appData/readJsonAsset): $e");
    }
  }
}
