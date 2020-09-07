import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' show Random;
import 'dart:async' show Timer;

Future main() async {
  Stream<HttpRequest> server;
  final port = 4044;
  final host = InternetAddress.loopbackIPv4;
  // WS
  final ws = await ServerSocket.bind('127.0.0.1', 5600);
  print('Listening on ws://127.0.0.1:5600');
  ws.listen((Socket socket) {
    print('Got connected ${socket.remoteAddress}');
    print('\t\thello'); // client will send JSON data
    Timer(Duration(seconds: 1), () {
      print("timer ${DateTime.now().toString()}");
    });
    for (int i = 0; i < 5; i++) {
      // socket.add(new Uint64List.fromList([i]).buffer.asUint8List());
    }
    print('Closed ${socket.remoteAddress}');
    // socket.close();
  });
  // final serverSocket = await ServerSocket.bind('127.0.0.1', 5600);
  // await for (Socket socket in serverSocket) {
  //   server.listen((Socket socket) {
  //     print('Got connected ${socket.remoteAddress}');

  //     for (int i = 0; i < 1024; i++) {
  //       socket.add(new Uint64List.fromList([i]).buffer.asUint8List());
  //     }
  //     socket.close();
  //     print('Closed ${socket.remoteAddress}');
  //   });
  //   // socket.listen(
  //   //   dataHandler,
  //   //   onError: errorHandler,
  //   //   onDone: () => {socket.destroy()},
  //   // );
  //   // print('Got connected ${socket.remoteAddress}');
  //   // for (int i = 0; i < 1024; i++) {
  //   //   socket.add(new Uint64List.fromList([i]).buffer.asUint8List());
  //   // }
  //   // socket.close();
  //   // stdin.listen(
  //   //     (data) => socket.write(new String.fromCharCodes(data).trim() + '\n'));
  // }
  // Http
  try {
    server = await HttpServer.bind(host, port);
    print('Listening on localhost:${port}');
  } catch (e) {
    print("Couldn't bind to port ${port}: $e");
    exit(-1);
  }

  await for (HttpRequest request in server) {
    handleRequest(request, host);
  }
}

void dataHandler(data) {
  print(new String.fromCharCodes(data).trim());
}

void errorHandler(error, StackTrace trace) {
  print(error);
}

Random intGenerator = Random();
int someRandomInt = intGenerator.nextInt(10);

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

void handleRequest(HttpRequest request, host) {
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
