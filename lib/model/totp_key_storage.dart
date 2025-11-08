import "dart:convert";

import "package:path_provider/path_provider.dart";
import "dart:io";
import "package:totp/model/totp_key.dart";

class TOTPKeyStorage {
  // 因为get是dart的关键字，为了避免歧义，持久化函数命名为read/write
  Future<List<TOTPKey>> read([bool? isTestMod]) async {
    List<TOTPKey> listIns = [];
    String fileStr = "";

    try {
      File fileIns = await _openFile(isTestMod);
      fileStr = await fileIns.readAsString();
    } catch (err) {
      return listIns;
    }

    for (var value in jsonDecode(fileStr)) {
      listIns.add(TOTPKey.fromJson(value));
    }

    return listIns;
  }

  Future<void> write(List<TOTPKey> list, [bool? isTestMod]) async {
    File fileIns = await _openFile(isTestMod);
    await fileIns.writeAsString(jsonEncode(list));
  }

  Future<File> _openFile([bool? isTestMod]) async {
    String keyFile = "totp_key.json";

    if (isTestMod != null && isTestMod) {
      return File("./$keyFile");
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;

    return File("$path/$keyFile");
  }
}
