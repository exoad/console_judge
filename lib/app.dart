import "dart:io";

import "package:args/args.dart";
import "package:console_judge/debug.dart";
import "package:console_judge/ephemeral.dart";
import "package:console_judge/shared.dart";
import "package:dart_console/dart_console.dart";

late ArgParser parser;
late Console console;

void init() {
  console = Console();
  parser = ArgParser();
  parser.addFlag("help", abbr: "h", help: "Print this usage information.");
  parser.addFlag("version",
      abbr: "v", help: "Get the versioning of Console Judge.");
  parser.addFlag("disable-capture",
      abbr: "d",
      help: "Disable the standard capture and compare test-cases mode.",
      defaultsTo: true);
  parser.addOption("src",
      abbr: "s",
      mandatory: true,
      help:
          "Specifies the source file. Supported file extensions: ${Strings.L_SupportedFileEndings}");
}

enum Lang {
  cxx(<String>["cxx", "cpp", "cc"]),
  c(<String>["c"]),
  java(<String>["java"]),
  python(<String>["py"]);

  final List<String> ext;

  const Lang(this.ext);
}

class TestSuite {
  final Lang lang;
  final String location;
  final bool useCaptureCompare;
  final String outFileLocation;

  const TestSuite(
      {required this.lang,
      required this.location,
      required this.useCaptureCompare,
      required this.outFileLocation});

  @override
  bool operator ==(covariant TestSuite other) {
    return lang == other.lang &&
        location.replaceAll("\\s+", "") ==
            other.location.replaceAll("\\s+", "");
  }

  @override
  String toString() =>
      "TestSuite_$hashCode[Lang=$lang,Location=$location,CaptureCompare=$useCaptureCompare]";
}

class AppMain {
  static void main(List<String> arguments) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      init();
      try {
        if (arguments.isEmpty) {
          G_Options["C_help"]!();
          return;
        } else {
          ArgResults results = parser.parse(arguments);
          $__TRACE("ArgumentsParsed=${results.arguments}");
          $__TRACE("Rest=${results.rest}");
          if (results.wasParsed("help") || !results.wasParsed("src")) {
            G_Options["C_help"]!();
            return;
          }
          if (results.wasParsed("version")) {
            G_Options["C_version"]!();
            return;
          }
        }
      } catch (ex) {
        if (ex is FormatException) {
          console.write(ex.message);
          console.writeLine();
          console.write(
              "Use '-h' or 'help' to get information on how to use this command.");
          console.writeLine();
        } else {
          throw ex;
        }
      }
    } else {
      throw UnsupportedError("Only Windows, Linux, and MacOS are supported");
    }
  }
}

void main(List<String> arguments) {
  AppMain.main(arguments);
}
