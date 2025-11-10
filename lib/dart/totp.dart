import 'dart:typed_data';
import 'dart:math';

import 'package:base32/base32.dart';
import 'package:crypto/crypto.dart';

(String, double) generateTOTP(String key) {
  try {
    Uint8List keyBytes = Uint8List.fromList(base32.decode(key.toUpperCase()));

    int timeNowSecond = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int timeCount = timeNowSecond ~/ 30;
    int timeRemain = 30 - timeNowSecond % 30; // use in return
    Uint8List timeCountBytes = _int2bytes(timeCount);

    Digest hash = Hmac(sha1, keyBytes).convert(timeCountBytes);

    int offset = hash.bytes.last & 0xf;
    int longPassword =
        (hash.bytes[offset] & 0x7f) << 24 |
        hash.bytes[offset + 1] << 16 |
        hash.bytes[offset + 2] << 8 |
        hash.bytes[offset + 3];

    int totp = longPassword % pow(10, 6).toInt();

    return (totp.toString().padLeft(6, "0"), timeRemain.toDouble());
  } catch (e) {
    return ("", 0.0);
  }
}

Uint8List _int2bytes(int long) {
  final byteArray = Uint8List(8);

  for (var index = byteArray.length - 1; index >= 0; index--) {
    final byte = long & 0xff;
    byteArray[index] = byte;
    long = (long - byte) ~/ 256;
  }

  return byteArray;
}
