import "dart:io";

import "package:console_judge/app.dart";
import "package:console_judge/shared.dart";

final class Strings {
  Strings._();

  static const String L_Copyright = "Copyright (C) 2024 Jiaming (Jack) Meng.";
  static const String L_DescriptionBlurb =
      "A simple console judge for running test-cases locally.";
  static const String L_Usage = "Usage: clij <command> [arguments]";
  static String get L_Version =>
      "ConsoleJudge build_ver: $kVersionNumber ($kBuildDate)";
  static final String L_SupportedFileEndings =
      "${Lang.cxx.ext.join(", ")}, ${Lang.c.ext.join(",")}, ${Lang.java.ext.join(",")}, ${Lang.python.ext.join(",")}";
}

final class Flags {
  Flags._();

  static String get cppFlags {
    StringBuffer buffer = StringBuffer();
    buffer.write(
        "-Wall -Wextra -O2 -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -fsanitize=undefined -Wshadow -Wformat=2 -Wfloat-equal -Wconversion -Wlogical-op -Wshift-overflow=2 -Wduplicated-cond -Wcast-qual -Wcast-align");
    if (Platform.isLinux) {
      buffer.write(" -D_FORTIFY_SOURCE=2");
    }
    return buffer.toString();
  }
}

final class Codes {
  Codes._();

  static const int kOk = 0;
  static const int kInCompleteArgumentsSupplied = 200;
  static const int kDefaultNoProcess = 201;
}
