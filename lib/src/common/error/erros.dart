import 'dart:async';

String _message = "";
String _code = "";
bool _sendcode = false;

set setMesage(String? message) {
  _message = message!;
}

set setCode(String? code) {
  _code = code!;
}

String _codeError = "";

String get getMessage => _message;
String get getCode => _code;
String get getCodeError => _codeError;
bool get sentCode => _sendcode;
StreamController<bool> codeSent = StreamController.broadcast();
Stream<bool> get getcodeSent => codeSent.stream;