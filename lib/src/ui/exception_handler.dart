import 'dart:html';
import 'package:angular2/core.dart';


class _ArrayLogger {
  List res = [];
  void log(dynamic s) {
    this.res.add(s);
  }

  void logError(dynamic s) {
    this.res.add(s);
  }

  void logGroup(dynamic s) {
    this.res.add(s);
  }

  void logGroupEnd() {}
}

class CustomExceptionHandler extends ExceptionHandler {
  CustomExceptionHandler() : super(new _ArrayLogger());

  @override
  void call(dynamic exception, [dynamic stackTrace = null, String reason = null]) {
    window.alert("Something went terribly wrong: $exception");
    super.call(exception, stackTrace, reason);
  }


}