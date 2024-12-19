import 'package:flutter/material.dart';

debug(dynamic arg) {
  var stackTrace = StackTrace.current;
  RegExp regExp = RegExp(r'\((.*?)\)');
  debugPrint(
      'Value: ${arg.toString()} at: ${regExp.firstMatch(stackTrace.toString().split('\n')[1])!.group(1)}');
}
