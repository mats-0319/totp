import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:totp/dart/result.dart';
import 'package:totp/model/totp_key.dart';
import 'package:totp/model/totp_key_list.dart';

Future<Result<String>> export(TOTPKeyList l) async {
  final fileStr = jsonEncode(l.list);

  final uri = await FilePicker.saveFile(
    fileName: "totp_key.txt",
    bytes: Uint8List.fromList(utf8.encode(fileStr)),
  );
  if (uri == null) {
    return Failure(err: "");
  }

  return Success(data: uri.toString()); // 不要依赖这个uri，它是android处理后的路径
}

Future<Result<void>> import(TOTPKeyList l) async {
  try {
    final file = await FilePicker.pickFile();
    if (file == null) {
      // 用户取消选择
      throw "";
    }

    final int fileSize = await file.length();
    if (fileSize > 1 << 20) {
      throw "文件过大，请导入小于1M的配置文件，当前文件大小：$fileSize";
    }

    final Uint8List fileBytes = await file.readAsBytes();
    final String fileStr = utf8.decode(fileBytes);

    List<TOTPKey> list = [];
    for (var value in jsonDecode(fileStr)) {
      list.add(TOTPKey.fromJson(value));
    }

    var res = await l.createList(list);
    if (res is Failure) {
      throw res.err;
    }
  } catch (e) {
    if (e.toString().isEmpty) {
      return Failure(err: "");
    }

    return Failure(err: "导入失败：${e.toString()}");
  }

  return Success(data: null);
}
