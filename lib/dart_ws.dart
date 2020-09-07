import 'dart:io';
import 'ws.dart';
import 'http.dart';

Future run() async {
  Stream<HttpRequest> server;
  final port = 4044;
  final host = InternetAddress.loopbackIPv4;
  // Http
  try {
    server = await HttpServer.bind(host, port);
    print('Listening on localhost:${port}');
    print('Listening on ws://127.0.0.1:${port}/ws');
  } catch (e) {
    print("Couldn't bind to port ${port}: $e");
    exit(-1);
  }
  await for (HttpRequest request in server) {
    if (request.uri.path == '/ws') {
      var socket = await WebSocketTransformer.upgrade(request);
      socket.listen((data) => handleSocket(data, socket));
    } else {
      handleHttp(request, host);
    }
  }
}
