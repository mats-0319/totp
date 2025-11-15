import 'dart:convert';
import 'dart:io';
import 'package:base32/base32.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'totp_key.dart';

class TOTPKeyList extends ChangeNotifier {
  // 为了保证使用`TOTPKeyList()`可以调用到同一实例，以及watch的时候能正确监听到实例的变化
  static final TOTPKeyList _instance = TOTPKeyList._privateInit();

  TOTPKeyList._privateInit();

  factory TOTPKeyList() {
    return _instance;
  }

  List<TOTPKey> list = [];

  Future<void> initialize() async {
    list = await read();
  }

  Future<void> create(TOTPKey keyIns) async {
    try {
      base32.decode(keyIns.key);
    } catch (_) {
      throw "\"${keyIns.key}\"不是有效的base32字符串";
    }

    int index = _getIndex(keyIns.key);
    if (index >= 0) {
      throw "\"${keyIns.key}\"已存在";
    }

    list.add(keyIns);

    await write(list);
    notifyListeners();
  }

  Future<void> update() async {
    await write(list);
    notifyListeners();
  }

  Future<void> delete(String key) async {
    int index = _getIndex(key);
    if (index < 0) {
      return; // target 'key' not exist
    }

    list[index].isDeleted = true;

    await write(list);
    notifyListeners();
  }

  Future<void> deleteHard(String key) async {
    int index = _getIndex(key);
    if (index < 0) {
      return; // target 'key' not exist
    }

    list.removeAt(index);

    await write(list);
    notifyListeners();
  }

  Future<void> reOrder(String key, int wantedIndex) async {
    int index = _getIndex(key);
    if (index < 0) {
      return; // target 'key' not exist
    }

    if (wantedIndex > index) {
      wantedIndex--;
    }

    TOTPKey keyIns = list[index];
    list.removeAt(index);
    list.insert(wantedIndex, keyIns);

    await write(list);
    notifyListeners();
  }

  // for test
  String display() {
    String res = "";
    res = "> TOTP key list length: ${list.length}\n";
    for (var i = 0; i < list.length; i++) {
      res += "> item $i: ";
      if (list[i].key.isEmpty) {
        res += "is empty.\n";
      } else if (list[i].isDeleted) {
        res +=
            "is deleted.\n"
            "  key: ${list[i].key},\n";
      } else {
        res +=
            "\n"
            "  key: ${list[i].key},\n"
            "  name: ${list[i].name},\n"
            "  autoActive: ${list[i].autoActive},\n"
            "  isDeleted: ${list[i].isDeleted},\n";
      }
    }

    return res;
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
