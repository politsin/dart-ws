import 'dart:io';
import 'dart:convert';
// import 'dart:typed_data';
// import "dart:isolate";
// import 'dart:math' show Random;
import 'dart:async' show Timer;

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
    handleRequest(request, host);
  }
}

void handleSocket(data, socket) {
  print('get MSG: ${data.toString()}');
  socket.add('echo ${data.toString()}');
  Timer(Duration(seconds: 1), () {
    print('timer ${DateTime.now().toString()}');
    socket.add('1s timer');
    handleSocket(data, socket);
  });
}

void handleRequest(HttpRequest request, host) async {
  if (request.uri.path == '/ws') {
    var socket = await WebSocketTransformer.upgrade(request);
    socket.listen((data) => handleSocket(data, socket));
  } else {
    try {
      if (request.method == 'GET') {
        handleGet(request, host);
      } else {
        request.response
          ..statusCode = HttpStatus.methodNotAllowed
          ..write('Unsupported request: ${request.method}.')
          ..close();
      }
    } catch (e) {
      print('Exception in handleRequest: $e');
    }
    print('Request handled.');
  }
}

void handleGet(HttpRequest request, host) {
  final response = request.response;
  final q = request.uri.queryParameters['q'];
  response
    ..statusCode = HttpStatus.ok
    ..write('Request: ${request.method}.');
  if (q == '33') {
    response..writeln('true');
    response..writeln('host: ${host.host}');
  } else if (q == 'json') {
    const jsonData = <String, String>{
      'name': 'Han Solo',
      'job': 'reluctant hero',
      'BFF': 'Chewbacca',
      'ship': 'Millennium Falcon',
      'weakness': 'smuggling debts',
    };
    response
      // WTF? response..headers.contentType = ContentType.json;
      // ..headers.add('Content-Type', 'application/json')
      ..writeln(jsonEncode(jsonData))
      ..close();
  }
  response.close();
}
