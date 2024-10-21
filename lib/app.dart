import "dart:io";

import "package:args/args.dart";
import "package:console_judge/debug.dart";
import "package:console_judge/ephemeral.dart";
import "package:console_judge/shared.dart";
import "package:dart_console/dart_console.dart";

import "util.dart";

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
  parser.addFlag("noflags",
      defaultsTo: false,
      help:
          "Dont' use default flags for the compiling language. Default enabled.");
  parser.addOption("lang",
      abbr: "l",
      mandatory: false,
      help:
          "Forces the judge to use a different runner. Use '--runners' to get a list of supported runners.");
  parser.addOption("src",
      mandatory: true,
      aliases: <String>["s"],
      help:
          "Specifies the source file. Supported file extensions: ${Strings.L_SupportedFileEndings}");
}

enum Lang {
  cxx("C++", <String>["cxx", "cpp", "cc"]),
  c("C", <String>["c"]),
  java("Java", <String>["java", "jav"]),
  python("Python", <String>["py"]);

  final List<String> ext;
  final String canonicalName;

  const Lang(this.canonicalName, this.ext);
}

String getExecFileExtension(Lang lang) => switch (lang) {
      Lang.cxx || Lang.c => Platform.isWindows ? "exe" : "out",
      Lang.java => "class",
      Lang.python => "pyc",
    };

Lang getLang(String file) {
  String ext = file.split(".").last;
  if (Lang.cxx.ext.contains(ext)) {
    return Lang.cxx;
  } else if (Lang.java.ext.contains(ext)) {
    return Lang.java;
  } else if (Lang.c.ext.contains(ext)) {
    return Lang.c;
  } else if (Lang.python.ext.contains(ext)) {
    return Lang.python;
  }
  throw UnsupportedError("In file $file is not supported by $kAppName");
}

enum Runners {
  cxx23(<String>["cxx23", "c++23", "cpp23"], Lang.cxx),
  cxx20(<String>["cxx20", "c++20", "cpp20"], Lang.cxx),
  cxx17(<String>["cxx17", "c++17", "cpp17"], Lang.cxx),
  cxx11(<String>["cxx11", "c++11", "cpp11"], Lang.cxx),
  cxx14(<String>["cxx14", "c++14", "cpp14"], Lang.cxx),
  cxx0x(<String>["cxx0x", "c++0x", "cpp0x", "gnu++0x"], Lang.cxx),
  c11(<String>["c", "c11"], Lang.c),
  c17(<String>["c17", "gnu17"], Lang.c);

  final List<String> aliases;
  final Lang associated;

  const Runners(this.aliases, this.associated);
}

@strict()
({String compile, String executor}) compose(
    {required String inFile,
    required String outFile,
    Runners? runner,
    bool useDefaultFlags = true}) {
  if (!Lang.python.ext.contains(inFile.split(".").last) && kEnforceChecks) {
    $__ASSERT(outFile == inFile, "Python requires dev outFile==inFile (full)");
  }
  StringBuffer buffer = StringBuffer();
  if (Lang.cxx.ext.contains(inFile.split(".").last.trim())) {
    buffer.write("g++ ");
    if (kEnforceChecks) {
      $__ASSERT(outFile.split(".").last == getExecFileExtension(Lang.cxx),
          "Internal error to resolve correct file extension failed for Lang.CXX");
    }
    if (runner != null) {
      buffer.write(" --std=");
      buffer.write(switch (runner) {
        Runners.cxx23 => "c++23",
        Runners.cxx0x => "gnu++0x",
        Runners.cxx14 => "c++14",
        Runners.cxx17 => "c++17",
        Runners.cxx11 => "c++11",
        Runners.cxx20 => "c++20",
        _ => throw UnsupportedError("Lang C++ does not support Runner $runner")
      });
    }
    buffer.write(
        "${useDefaultFlags ? "${Flags.cppFlags} " : ""}$inFile -o $outFile");
    return (
      compile: buffer.toString(),
      executor: ".${Platform.pathSeparator}$outFile"
    );
  } else if (Lang.java.ext.contains(inFile.split(".").last.trim())) {
    if (kEnforceChecks) {
      $__ASSERT(outFile.split(".").last == getExecFileExtension(Lang.java),
          "Internal error to resolve correct file extension failed for Lang.JAVA");
    }
    buffer.write("javac $inFile");
    return (compile: buffer.toString(), executor: "java $outFile");
  } else if (Lang.python.ext.contains(inFile.split(".").last.trim())) {
    buffer.write("python ");
    buffer.write(inFile);
    return (compile: buffer.toString(), executor: buffer.toString());
  } else if (Lang.c.ext.contains(inFile.split(".").last.trim())) {
    if (kEnforceChecks) {
      $__ASSERT(outFile.split(".").last == getExecFileExtension(Lang.c),
          "Internal error to resolve correct file extension failed for Lang.C");
    }
    return (
      compile: buffer.toString(),
      executor: ".${Platform.pathSeparator}$outFile"
    );
  }
  throw "Unsupported language (file extension) of ${inFile.split(".").last.trim()}";
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
  static Future<void> main(List<String> arguments) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      if (kAllowDebugTracing) {
        $__TRACE("TRACING IS ENABLED. PLEASE TURN OFF FOR PRODUCTION MODE");
      }
      init();
      try {
        if (arguments.isEmpty) {
          G_Options["C_help"]!();
          $__FINAL("Detect: none args, running as results.flag('help')");
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
            (String, Lang) outFile =
                G_Options["C_src"]!(<String>[results.option("src")!]) as (
              String,
              Lang
            );
            ({String compile, String executor}) commands = compose(
                inFile: results.option("src")!,
                outFile: outFile.$2 == Lang.python
                    ? results.option("src")!
                    : outFile.$1,
                useDefaultFlags: !results.flag("noflags"),
                runner: G_Options["C_lang"]!(results.option("lang") != null
                    ? <String>[results.option("lang")!]
                    : null));
            List<String> bits = commands.compile.split(" ");
            bits.remove(0);
            $__TRACE("Compiler=${commands.compile}");
            $__TRACE("Executor=${commands.executor}");
            Process.run(commands.compile.split(" ").first, bits);
            Process.run(commands.executor, <String>[]);
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
