import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:totp/dart/result.dart';
import 'package:totp/dart/totp.dart';

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
    var res = await read();
    switch (res) {
      case Success():
        if (res.data.isNotEmpty) {
          list = res.data;
        } else {
          await create(TOTPKey("NVQXE2LPNVQXE21", "demo", false));
          await create(TOTPKey("NVQXE2LPNVQXE22", "demo2", true));
        }
      case Failure():
      // todo：拟记录错误信息，加载主页面时，如果错误不空则优先加载错误信息；
      // 备份当前文件，然后初始化示例实例
    }
  }

  Future<Result<void>> createList(List<TOTPKey> l) async {
    List<TOTPKey> backup = list.toList();
    list = [];

    for (var k in l) {
      var res = isValidKeyIns(k);
      switch (res) {
        case Success():
          list.add(res.data);
        case Failure():
          list = backup;
          return res;
      }
    }

    await synchronized();

    return Success(data: null);
  }

  Future<Result<void>> create(TOTPKey keyIns) async {
    var res = isValidKeyIns(keyIns);
    switch (res) {
      case Success():
        list.add(res.data);
      case Failure():
        return res;
    }

    await synchronized();

    return Success(data: null);
  }

  Future<Result<void>> update(String keyBase32) async {
    var res = normalize(keyBase32);
    switch (res) {
      case Failure():
        return res;
      case Success():
    }

    Set<String> keys = {};
    for (var item in list) {
      if (!keys.add(item.key)) {
        return Failure(err: "更新失败，key：'${item.key}'已存在");
      }
    }

    await synchronized();

    return Success(data: null);
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

  Future<Result<String>> export() async {
    final fileStr = jsonEncode(TOTPKeyList().list);

    final uri = await FilePicker.saveFile(
      fileName: "totp_key.json",
      bytes: Uint8List.fromList(utf8.encode(fileStr)),
    );
    if (uri == null) {
      return Failure(err: "");
    }

    return Success(data: uri.toString());
  }

  Future<Result<void>> import() async {
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
      List<TOTPKey> l = [];
      for (var value in jsonDecode(fileStr)) {
        l.add(TOTPKey.fromJson(value));
      }

      var res = await createList(l);
      switch (res) {
        case Failure():
          return res;
        case Success():
      }
    } catch (e) {
      return Failure(err: "导入失败：${e.toString()}");
    }

    await synchronized();

    return Success(data: null);
  }

  Future<void> synchronized() async {
    await write(list);
    notifyListeners();
  }

  Result<TOTPKey> isValidKeyIns(TOTPKey keyIns) {
    var res = normalize(keyIns.key);
    switch (res) {
      case Success():
        keyIns.key = res.data;
      case Failure():
        return Failure(err: res.err);
    }

    int index = _getIndex(keyIns.key);
    if (index >= 0) {
      return Failure(err: "key:'${keyIns.key}'已存在");
    }

    return Success(data: keyIns);
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

Future<Result<List<TOTPKey>>> read() async {
  List<TOTPKey> listIns = [];

  try {
    File fileIns = await _openFile();
    String fileStr = await fileIns.readAsString();

    for (var value in jsonDecode(fileStr)) {
      listIns.add(TOTPKey.fromJson(value));
    }

    return Success(data: listIns);
  } catch (e) {
    return Failure(err: "加载本地文件失败，错误：${e.toString()}");
  }
}

Future<void> write(List<TOTPKey> list) async {
  File fileIns = await _openFile();
  await fileIns.writeAsString(jsonEncode(list));
}

Future<File> _openFile() async {
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;

  final dir = Directory(path);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  return File("$path/totp_key.json");
}
