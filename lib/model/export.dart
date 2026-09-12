import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:totp/dart/result.dart';
import 'package:totp/model/totp_key.dart';
import 'package:totp/model/totp_key_list.dart';

Future<Result<String>> export(TOTPKeyList l) async {
  final fileStr = jsonEncode(l.list);

  final uri = await FilePicker.saveFile(
    fileName: "totp_key.json",
    bytes: Uint8List.fromList(utf8.encode(fileStr)),
  );
  if (uri == null) {
    return Failure(err: "");
  }

  return Success(data: uri.toString());
}

Future<Result<void>> import(TOTPKeyList l) async {
  final file = await FilePicker.pickFile();
  if (file == null) {
    return Failure(err: "读取文件失败");
  }

  final int fileSize = await file.length();
  if (fileSize > 1 << 20) {
    return Failure(err: "文件过大，请导入小于1M的json配置，当前文件大小：$fileSize");
  }

  final Uint8List fileBytes = await file.readAsBytes();
  final String fileStr = utf8.decode(fileBytes);
  try {
    List<TOTPKey> list = [];
    for (var value in jsonDecode(fileStr)) {
      list.add(TOTPKey.fromJson(value));
    }

    var res = await l.createList(list);
    switch (res) {
      case Failure():
        return res;
      case Success():
    }
  } catch (e) {
    return Failure(err: "导入失败：${e.toString()}");
  }

  return Success(data: null);
}
