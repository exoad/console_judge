import "package:console_judge/app.dart";
import "package:console_judge/util.dart";
import "package:test/test.dart";

void main() {
  group("Esoteric", () {
    test("Output Random name", () {
      print(Util.getTempFileName("main.cxx", getExecFileExtension(Lang.cxx)));
    });
  });
}
