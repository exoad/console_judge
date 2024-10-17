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
const bool kEnforceChecks = true;
const bool kAllowDebugTracing = true;

final Map<String, dynamic Function([List<String>? arguments])> G_Options =
    <String, dynamic Function([List<String>? arguments])>{
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
  "C_src": ([List<String>? args]) {
    if (args == null) {
      G_Options["C_help"]!();
      $__FINAL("Detect_Fatal: C_src(null) resolved!",
          Codes.kInCompleteArgumentsSupplied);
    } else {
      String loc = args[0];
      if (loc.contains("/")) {
        loc = loc.split("/").last;
      } else if (loc.contains("\\")) {
        loc = loc.split("\\").last;
      }
      String end = Util.getTempFileName(loc);
      $__TRACE("C_src try to parse loc=$loc -> end=$end");
    }
  },
};
