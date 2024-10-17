import "dart:io";

import "package:console_judge/app.dart";
import "package:console_judge/ephemeral.dart";
import "package:console_judge/shared.dart";

@pragma("vm:prefer-inline")
void $__ASSERT(bool validity, [String? message]) {
  if (kEnforceChecks) {
    if (!validity) {
      if (message == null || message.isEmpty) {
        assert(false);
      } else {
        throw message;
      }
    }
  }
}

@pragma("vm:prefer-inline")
void $__FINAL(dynamic message, [int code = Codes.kOk]) {
  $__TRACE(message);
  exit(0);
}

@pragma("vm:prefer-inline")
void $__TRACE(dynamic message) {
  if (kAllowDebugTracing) {
    console.writeLine(
        "[${DateTime.now().toIso8601String()}] [__TRACE__] : $message");
  }
}
