import 'dart:async' show Timer;

void handleSocket(data, socket) {
  print('get MSG: ${data.toString()}');
  socket.add('echo ${data.toString()}');
  Timer(Duration(seconds: 1), () {
    print('timer ${DateTime.now().toString()}');
    socket.add('1s timer');
    handleSocket(data, socket);
  });
}
