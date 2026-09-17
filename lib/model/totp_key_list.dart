import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:totp/dart/kotlin_keystore.dart';
import 'package:totp/dart/result.dart';
import 'package:totp/dart/totp.dart';
import 'package:totp/model/file_operate.dart';
import 'package:totp/model/totp_key.dart';

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
    err = "";

    try {
      File fileIns = await openFile("totp_key.txt");
      Uint8List fileBytes = await fileIns.readAsBytes();

      List<TOTPKey> l = [];
      if (fileBytes.isNotEmpty) {
        var res = await AndroidKeyStore.decrypt(fileBytes);
        switch (res) {
          case Success():
            fileBytes = res.data;
          case Failure():
            await backupFile();
            throw res.err;
        }
        for (var value in jsonDecode(utf8.decode(fileBytes))) {
          l.add(TOTPKey.fromJson(value));
        }
      }
      if (l.isEmpty) {
        l = [
          TOTPKey("demo", "NVQXE2LPNVQXE2L2", false),
          TOTPKey("demo2", "NVQXE2LPNVQXE2L3", true),
        ];
      }

      var res = await createList(l);
      if (res is Failure) {
        throw res.err;
      }
    } catch (e) {
      err = e.toString();
      notifyListeners();
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

    return await synchronized(() => list = backup);
  }

  Future<Result<void>> create(TOTPKey keyIns) async {
    var res = isValidKeyIns(keyIns);
    switch (res) {
      case Success():
        list.add(res.data);
      case Failure():
        return res;
    }

    return await synchronized(() => list.removeLast());
  }

  Future<Result<void>> update(TOTPKey keyIns) async {
    var res = isValidKeyIns(keyIns, true);
    if (res is Failure) {
      return res;
    }

    return await synchronized(() {});
  }

  Future<Result<void>> deleteHard(String key) async {
    int index = _getIndex(key);
    if (index < 0) {
      return Success(data: null); // target 'key' not exist
    }

    var item = list.removeAt(index);

    return await synchronized(() => list.insert(index, item));
  }

  Future<Result<void>> synchronized(void Function() revert) async {
    var res = await write(list);
    switch (res) {
      case Success():
        notifyListeners();
      case Failure():
        revert();
    }

    return res;
  }

  Result<TOTPKey> isValidKeyIns(TOTPKey keyIns, [bool skipSameItem = false]) {
    var res = normalize(keyIns.key);
    switch (res) {
      case Success():
        keyIns.key = res.data;
      case Failure():
        return Failure(err: res.err);
    }

    for (var i = 0; i < list.length; i++) {
      if (keyIns.key == list[i].key) {
        if (skipSameItem) {
          skipSameItem = false;
        } else {
          return Failure(err: "Duplicate key: ${list[i].key}");
        }
      }
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

Future<Result<void>> write(List<TOTPKey> list) async {
  Uint8List fileBytes = utf8.encode(jsonEncode(list));
  Result<Uint8List> res = await AndroidKeyStore.encrypt(fileBytes);
  switch (res) {
    case Success():
      File fileIns = await openFile("totp_key.txt");
      await fileIns.writeAsBytes(res.data);
      return Success(data: null);
    case Failure():
      return res;
  }
}
