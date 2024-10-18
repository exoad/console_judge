import "dart:io";

import "package:console_judge/shared.dart";

final class Util {
  Util._();

  static String get executableFileExtension =>
      Platform.isWindows ? "exe" : "out";

  static const _chars =
      "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890";

  static String getRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(
          length, (_) => _chars.codeUnitAt(RNG.nextInt(_chars.length))));

  /// [original] should just be the file name itself (not some path)
  static String getTempFileName(String original, String execExtension) =>
      "${original.split(".").first}__${Util.getRandomString(10)}_\$\$clij.$execExtension";
}

class strict {
  const strict();
}
