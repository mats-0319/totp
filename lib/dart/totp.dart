import 'dart:typed_data';
import 'dart:math';
import 'package:base32/base32.dart';
import 'package:crypto/crypto.dart';

const int _timeInterval = 30;
const int _pwdLength = 6;

(String, double) generateTOTP(String keyBase32) {
  try {
    final Uint8List keyBytes = base32.decode(keyBase32.toUpperCase());

    final int timestampSecond = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final int timeRemain = _timeInterval - timestampSecond % _timeInterval;
    final int timeCount = timestampSecond ~/ _timeInterval;
    final Uint8List timeCountBytes = _int2Bytes(timeCount);

    final List<int> hash = Hmac(sha1, keyBytes).convert(timeCountBytes).bytes;

    final int offset = hash.last & 0xf; // 0b 0000 1111
    final int longPassword =
        (hash[offset] & 0x7f) << 24 | // 0b 0111 1111
        hash[offset + 1] << 16 |
        hash[offset + 2] << 8 |
        hash[offset + 3];

    final int totp = longPassword % pow(10, _pwdLength).toInt();

    return (totp.toString().padLeft(_pwdLength, "0"), timeRemain.toDouble());
  } catch (e) {
    return ("计算密码失败", _timeInterval.toDouble());
  }
}

Uint8List _int2Bytes(int long) {
  final byteArray = Uint8List(8);

  for (var index = byteArray.length - 1; index >= 0; index--) {
    byteArray[index] = long & 0xff;
    long >>= 8;
  }

  return byteArray;
}
