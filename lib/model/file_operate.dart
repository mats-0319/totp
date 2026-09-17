import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:totp/dart/result.dart';
import 'package:totp/model/totp_key.dart';
import 'package:totp/model/totp_key_list.dart';

Future<Result<String>> export(TOTPKeyList l) async {
  try {
    final file = await openFile("totp_key.json");
    await file.writeAsString(jsonEncode(l.list));
    return Success(data: file.path);
  } catch (e) {
    return Failure(err: e.toString());
  }
}

Future<Result<void>> import(TOTPKeyList l) async {
  try {
    final directory = await getExternalStorageDirectory();
    final file = File("${directory?.path}/totp_key.json");

    if (!await file.exists()) {
      throw "File('totp_key.json') not found";
    }

    final fileBytes = await file.readAsBytes();
    final fileStr = utf8.decode(fileBytes);

    List<TOTPKey> list = [];
    for (var item in jsonDecode(fileStr)) {
      list.add(TOTPKey.fromJson(item));
    }

    return await l.createList(list);
  } catch (e) {
    return Failure(err: e.toString());
  }
}

Future<File> openFile(String fileName) async {
  final directory = await getExternalStorageDirectory();
  final file = File("${directory?.path}/$fileName");

  if (!await file.exists()) {
    await file.create(recursive: true);
  }

  return file;
}

Future<void> backupFile() async {
  final directory = await getExternalStorageDirectory();
  final file = File("${directory?.path}/totp_key.txt");

  if (!await file.exists()) {
    return;
  }

  final now = DateTime.now().millisecondsSinceEpoch;
  final newFileName = "${directory?.path}/totp_key.txt.$now";

  await file.rename(newFileName);
}
