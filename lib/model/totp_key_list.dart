import 'dart:convert';
import 'dart:io';

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
  String err = "";

  Future<void> initialize() async {
    List<TOTPKey> demoInstanceList = [
      TOTPKey("demo", "NVQXE2LPNVQXE2L2", false),
      TOTPKey("demo2", "NVQXE2LPNVQXE2L3", true),
    ];

    List<TOTPKey> l = [];

    try {
      File fileIns = await _openFile();
      String fileStr = await fileIns.readAsString();

      for (var value in jsonDecode(fileStr)) {
        l.add(TOTPKey.fromJson(value));
      }

      if (l.isEmpty) {
        l = demoInstanceList;
      }
    } catch (e) {
      err = e.toString();
      _backupFile();
      l = demoInstanceList;
    }

    var res = await createList(l);
    switch (res) {
      case Failure():
        err = res.err;
      case Success():
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

Future<String> _backupFile() async {
  File f = await _openFile();
  int timestamp = DateTime.now().millisecondsSinceEpoch;

  String newFileName = "${f.path}/totp_key_$timestamp.json";
  await f.copy(newFileName);

  return newFileName;
}
