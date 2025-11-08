import 'package:otp/otp.dart';
import 'package:totp/model/totp_key.dart';
import 'package:flutter/material.dart';
import 'package:totp/model/totp_key_storage.dart';

class TOTPKeyList extends ChangeNotifier {
  // 为了保证使用`TOTPKeyList()`可以调用到同一实例，以及watch的时候能正确监听到实例的变化
  static final TOTPKeyList _instance = TOTPKeyList._privateInit();

  TOTPKeyList._privateInit();

  factory TOTPKeyList() {
    return _instance;
  }

  List<TOTPKey> list = [];

  Future<void> initialize() async {
    list = await TOTPKeyStorage().read();
  }

  Future<void> create(TOTPKey key) async {
    int index = _getIndex(key.key);
    if (index >= 0) {
      return; // 'key' already exist
    }

    list.add(key);

    await TOTPKeyStorage().write(list);
    notifyListeners();
  }

  Future<void> update(TOTPKey key) async {
    int index = _getIndex(key.key);
    if (index < 0) {
      return; // target 'key' not exist
    }

    list[index] = key;

    await TOTPKeyStorage().write(list);
    notifyListeners();
  }

  Future<void> delete(String key) async {
    int index = _getIndex(key);
    if (index < 0) {
      return; // target 'key' not exist
    }

    list[index].isDeleted = true;

    await TOTPKeyStorage().write(list);
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

(String, double) generateTOTP(String key) {
  return (
    OTP.generateTOTPCodeString(
      key,
      DateTime.now().millisecondsSinceEpoch,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    ),
    OTP.remainingSeconds().toDouble(),
  );
}
