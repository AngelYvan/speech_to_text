import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:http/http.dart' as http;

/*Future<Post> fetchPost() async {
  final response =
      await http.get('https://domotica-pe.herokuapp.com/rest/temperatura.php');

  if (response.statusCode == 200) {
    // Si la llamada al servidor fue exitosa, analiza el JSON
    return Post.fromJson(json.decode(response.body)[0]);
  } else {
    // Si la llamada no fue exitosa, lanza un error.
    throw Exception('Failed to load post');
  }
}

class Post {
  final tem_valor;

  Post({this.tem_valor});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      tem_valor: json['tem_valor'],
    );
  }
}*/
fetchVentilador(String val) async {
  var url = 'https://domotica-pe.herokuapp.com/rest/ventilador.php';
  var response = await http.post(url, body: {'ven_valor': val});
}

fetchCalefactor(String val) async {
  var url = 'https://domotica-pe.herokuapp.com/rest/calefactor.php';
  var response = await http.post(url, body: {'cal_valor': val});
}


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasSpeech = false;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  final SpeechToText speech = SpeechToText();

  @override
  void initState() {
    super.initState();
    initSpeechState();
  }

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);

    if (!mounted) return;
    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Domotica Plataformas Emergentes'),
        ),
        body: _hasSpeech
            ? Column(children: [
                Expanded(
                  child: Center(
                    child: Text('Reconocimiento de Voz Disponible'),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FlatButton(
                        child: Text('Iniciar'),
                        onPressed: startListening,
                      ),
                      FlatButton(
                        child: Text('Detener'),
                        onPressed: stopListening,
                      ),
                      FlatButton(
                        child: Text('Cancelar'),
                        onPressed: cancelListening,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: Text('Palabras Reconocidas'),
                      ),
                      Center(
                        child: Text(lastWords),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: Text('Error'),
                      ),
                      Center(
                        child: Text(lastError),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: speech.isListening
                        ? Text("Estoy escuchando...")
                        : Text('No escucho'),
                  ),
                ),
              ])
            : Center(
                child: Text('Reconocimiento de voz no disponible',
                    style: TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.bold))),
      ),
    );
  }

  void startListening() {
    lastWords = "";
    lastError = "";
    speech.listen(onResult: resultListener, listenFor: Duration(seconds: 10));
    setState(() {});
  }

  void stopListening() {
    speech.stop();
    setState(() {});
  }

  void cancelListening() {
    speech.cancel();
    setState(() {});
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = "${result.recognizedWords} - ${result.finalResult}";
      if ((lastWords.toLowerCase()).compareTo('encender ventilador - true') == 0) {
        fetchVentilador('1');
        lastWords = 'encender ventilador 1';
      }
      if ((lastWords.toLowerCase()).compareTo('apagar ventilador - true') == 0) {
        fetchVentilador('0');
        lastWords = 'apagar ventilador 0';
      }
      if ((lastWords.toLowerCase()).compareTo('encender calefactor - true') == 0) {
        fetchCalefactor('1');
        lastWords = 'encender calefactor 1';
      }
      if ((lastWords.toLowerCase()).compareTo('apagar calefactor - true') == 0) {
        fetchCalefactor('0');
        lastWords = 'apagar calefactor 0';
      }
      //lastWords=lastWords+" paso";
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = "$status";
    });
  }
}
