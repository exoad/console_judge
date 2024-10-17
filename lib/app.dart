import "dart:io";

import "package:args/args.dart";
import "package:console_judge/debug.dart";
import "package:console_judge/ephemeral.dart";
import "package:console_judge/shared.dart";
import "package:dart_console/dart_console.dart";

late ArgParser parser;
final Console console = Console();

void init() {
  parser = ArgParser();
  parser.addFlag("help", abbr: "h", help: "Print this usage information.");
  parser.addFlag("version",
      abbr: "v", help: "Get the versioning of Console Judge.");
  parser.addFlag("no-capture",
      help: "Disable the standard capture and compare test-cases mode.",
      defaultsTo: true);
  parser.addFlag("runners", help: "Get a list of supported language versions");
  parser.addOption("lang",
      abbr: "l",
      mandatory: false,
      help:
          "Forces the judge to use a different runner. Use '--runners' to get a list of supported runners.");

  parser.addOption("src",
      abbr: "s",
      mandatory: true,
      help:
          "Specifies the source file. Supported file extensions: ${Strings.L_SupportedFileEndings}");
}

enum Lang {
  cxx("C++", <String>["cxx", "cpp", "cc"]),
  c("C", <String>["c"]),
  java("Java", <String>["java"]),
  python("Python", <String>["py"]);

  final List<String> ext;
  final String canonicalName;

  const Lang(this.canonicalName, this.ext);
}

enum Runners {
  cxx23(<String>["cxx23", "c++23", "cpp23"], Lang.cxx),
  cxx20(<String>["cxx20", "c++20", "cpp20"], Lang.cxx),
  cxx17(<String>["cxx17", "c++17", "cpp17"], Lang.cxx),
  cxx14(<String>["cxx14", "c++14", "cpp14"], Lang.cxx),
  cxx0x(<String>["cxx0x", "c++0x", "cpp0x"], Lang.cxx),
  c11(<String>["c", "c11"], Lang.c),
  c17(<String>["c17", "gnu17"], Lang.c);

  final List<String> aliases;
  final Lang associated;

  const Runners(this.aliases, this.associated);
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
      if (kAllowDebugTracing) {
        $__TRACE("TRACING IS ENABLED. PLEASE TURN OFF FOR PRODUCTION MODE");
      }
      init();
      try {
        if (arguments.isEmpty) {
          G_Options["C_help"]!();
          return;
        } else {
          ArgResults results = parser.parse(arguments);
          $__TRACE("ArgumentsParsed=${results.arguments}");
          $__TRACE("Rest=${results.rest}");
          $__TRACE("Options=${results.options}");
          // ! PARSE ALL FLAGS
          if (results.flag("help")) {
            G_Options["C_help"]!();
            $__FINAL("Detect: results.flag('help')");
          }
          if (results.flag("version")) {
            G_Options["C_version"]!();
            $__FINAL("Detect: results.flag('version')");
          }
          if (results.flag("runners")) {
            G_Options["C_runners"]!();
            $__FINAL("Detect: results.flag('runners')");
          }
          // ! PARSE ALL OPTIONS/COMMANDS
          if (results.option("src") == null) {
            G_Options["C_help"]!();
            $__FINAL("Detect: results.option('src') == null");
          } else {
            G_Options["C_src"]!(<String>[results.option("src")!]);
            $__FINAL(
                "Detect: results.option('src') == ${results.option("src")}");
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
