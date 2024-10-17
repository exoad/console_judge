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
