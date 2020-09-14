import 'dart:io';
import 'dart:convert';

void handleHttp(HttpRequest request, host) async {
  try {
    if (request.method == 'GET') {
      handleGet(request, host);
    } else {
      request.response
        ..statusCode = await HttpStatus.methodNotAllowed
        ..write('Unsupported request: ${request.method}.')
        ..close();
    }
  } catch (e) {
    print('Exception in handleRequest: $e');
  }
  print('Request handled.');
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
