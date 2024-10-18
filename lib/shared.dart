import "dart:io";
import "dart:math";

import "package:console_judge/app.dart";
import "package:console_judge/debug.dart";
import "package:console_judge/ephemeral.dart";
import "package:console_judge/ext/string_buffer.dart";
import "package:console_judge/util.dart";

const String kAppName = "Console Judge";
const int kVersionNumber = 1;
const int kBuildDate = 20241020;

final Random RNG = Random(DateTime.now().millisecondsSinceEpoch);

/// These properties should only ever be [true] when in dev mode
const bool kEnforceChecks = false;
const bool kAllowDebugTracing = true;

final Map<Lang, String Function(String location)> G_executors =
    <Lang, String Function(String location)>{};

final Map<String, dynamic Function([List<String>? arguments])> G_Options =
    <String, dynamic Function([List<String>? arguments])>{
  "C_runners": ([List<String>? _]) {
    StringBuffer buffer = StringBuffer();
    buffer.writeln("Console Judge all supported Runners");
    Map<Lang, List<List<String>>> versions = <Lang, List<List<String>>>{};
    for (Runners e in Runners.values) {
      if (versions.containsKey(e.associated)) {
        versions[e.associated]!.add(e.aliases);
      } else {
        versions[e.associated] = <List<String>>[e.aliases];
      }
    }
    buffer.writeNewLine();
    for (Lang l in versions.keys) {
      buffer.writeln(l.canonicalName);
      int i = 1;
      for (List<String> all in versions[l]!) {
        buffer.writeln("  $i) \"${all[0]}\" : ${all.sublist(1).join(", ")}");
        i++;
      }
    }
    console.write(buffer.toString());
  },
  "C_version": ([List<String>? _]) {
    console.write(Strings.L_Version);
    console.writeLine();
    return;
  },
  "C_help": ([List<String>? _]) {
    StringBuffer buffer = StringBuffer();
    buffer.write(
        "${kAppName}\n${Strings.L_DescriptionBlurb}\n${Strings.L_Copyright}\n\n${Strings.L_Usage}\n\nGlobal options:\n");
    const int abbrWidth = 5;
    for (String k in parser.options.keys) {
      var option = parser.options[k];
      $__ASSERT(
          option != null, "ARG for $k in 'parser.options' cannot be null");
      String abbr = option!.abbr != null ? "-${option.abbr}" : "";
      abbr = abbr.padRight(abbrWidth);
      String optionName = "--${option.name}".padRight(12);
      String description = option.help ?? "[No Description]";
      buffer.write("$abbr| $optionName| $description\n");
    }
    buffer.writeNewLine();
    console.write(
      buffer.toString(),
    );
    return;
  },
  "C_src": ([List<String>? args]) /* [ void | int ] */ {
    if (args == null) {
      G_Options["C_help"]!();
      $__FINAL("Detect_Fatal: C_src(null) resolved!",
          Codes.kInCompleteArgumentsSupplied);
    } else {
      String loc = args[0];
      if (!File(loc).existsSync()) {
        throw "Input source file '$loc' does not exist!";
      }
      late String outFile;
      if (!Lang.python.ext.contains(loc.split(".").last)) {
        String fileName = loc.contains("/")
            ? loc.split("/").last
            : loc.contains("\\")
                ? loc.split("\\").last
                : loc;
        String totalPath = loc.contains("/")
            ? (loc.split("/")..removeLast()).join("/")
            : loc.contains("\\")
                ? (loc.split("\\")..removeLast()).join("\\")
                : "";
        String newFileName = Util.getTempFileName(
            fileName, getExecFileExtension(getLang(fileName)));
        File out = File(totalPath + newFileName);
        if (out.existsSync()) {
          out.deleteSync();
        }
        outFile = "$totalPath${Platform.pathSeparator}$newFileName";
      }
      $__TRACE("outFile = $outFile");
    }
  },
};
