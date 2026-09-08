import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:base32/base32.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'totp_key.dart';

class TOTPKeyList extends ChangeNotifier {
  static final TOTPKeyList _instance = TOTPKeyList._privateInit();

  TOTPKeyList._privateInit();

  // 工厂构造函数，每次调用返回相同实例
  factory TOTPKeyList() {
    return _instance;
  }

  List<TOTPKey> list = [];

  Future<void> initialize() async {
    list = await read();
  }

  Future<void> create(TOTPKey keyIns) async {
    if (keyIns.key.isEmpty) {
      throw "key不能为空";
    }

    try {
      base32.decode(keyIns.key);
    } catch (_) {
      throw "key:'${keyIns.key}'不是有效的base32字符串";
    }

    int index = _getIndex(keyIns.key);
    if (index >= 0) {
      throw "key:'${keyIns.key}'已存在";
    }

    list.add(keyIns);

    await synchronized();
  }

  Future<void> update(String keyBase32) async {
    try {
      base32.decode(keyBase32);
    } catch (_) {
      throw "key:'$keyBase32'不是有效的base32字符串";
    }

    await synchronized();
  }

  Future<void> delete(String key) async {
    int index = _getIndex(key);
    if (index < 0) {
      return; // target 'key' not exist
    }

    list[index].isDeleted = true;

    await synchronized();
  }

  Future<void> deleteHard(String key) async {
    int index = _getIndex(key);
    if (index < 0) {
      return; // target 'key' not exist
    }

    list.removeAt(index);

    await synchronized();
  }

  Future<String> export() async {
    final fileStr = jsonEncode(TOTPKeyList().list);

    final uri = await FilePicker.saveFile(
      fileName: "totp_key.json",
      bytes: Uint8List.fromList(utf8.encode(fileStr)),
    );
    if (uri == null) {
      return "";
    }

    return uri.toString();
  }

  Future<void> import() async {
    final file = await FilePicker.pickFile();
    if (file == null) {
      throw "读取文件失败";
    }

    final int fileSize = await file.length();
    if (fileSize > 1 << 20) {
      throw "文件过大，请导入小于1M的json配置，当前文件大小：$fileSize";
    }

    list = [];
    final Uint8List fileBytes = await file.readAsBytes();
    final String fileStr = utf8.decode(fileBytes);
    for (var value in jsonDecode(fileStr)) {
      try {
        final TOTPKey k = TOTPKey.fromJson(value);
        create(k);
      } catch (e) {
        rethrow;
      }
    }

    await synchronized();
  }

  Future<void> synchronized() async {
    await write(list);
    notifyListeners();
  }

  // _getIndex return index of target 'key' in this.list,
  // if target 'key' is NOT exist, return -1
  int _getIndex(String key) {
    int index = 0;
    for (; index < list.length; index++) {
      if (list[index].key == key) {
        break;
      }
    }

    if (index >= list.length) {
      index = -1;
    }

    return index;
  }
}

Future<List<TOTPKey>> read() async {
  List<TOTPKey> listIns = [];
  String fileStr = "";

  try {
    File fileIns = await _openFile();
    fileStr = await fileIns.readAsString();
  } catch (err) {
    return listIns;
  }

  for (var value in jsonDecode(fileStr)) {
    listIns.add(TOTPKey.fromJson(value));
  }

  return listIns;
}

Future<void> write(List<TOTPKey> list) async {
  File fileIns = await _openFile();
  await fileIns.writeAsString(jsonEncode(list));
}

Future<File> _openFile() async {
  String keyFile = "totp_key.json";

  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;

  return File("$path/$keyFile");
}
