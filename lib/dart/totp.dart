import 'dart:typed_data';

import 'package:base32/base32.dart';
import 'package:crypto/crypto.dart';
import 'package:totp/dart/result.dart';

// 验证码有效期（秒），RFC 6238 默认 30 秒
const int totpTimeInterval = 30;
const int _pwdLength = 6;

Result<String> generateTOTP(String keyBase32) {
  var res = normalize(keyBase32);
  switch (res) {
    case Success():
      keyBase32 = res.data;
    case Failure():
      return res;
  }

  try {
    final Uint8List keyBytes = base32.decode(keyBase32);

    final int timestampSecond = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final int timeCount = timestampSecond ~/ totpTimeInterval;
    final Uint8List timeCountBytes = _int2Bytes(timeCount);

    final List<int> hash = Hmac(sha1, keyBytes).convert(timeCountBytes).bytes;

    final int offset = hash.last & 0xf; // 0b 0000 1111
    final int longPassword =
        (hash[offset] & 0x7f) << 24 | // 0b 0111 1111
        hash[offset + 1] << 16 |
        hash[offset + 2] << 8 |
        hash[offset + 3];

    final int totp = longPassword % 1_000_000;

    return Success(data: totp.toString().padLeft(_pwdLength, "0"));
  } catch (e) {
    return Failure(err: "计算密码失败：${e.toString()}");
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

Result<String> normalize(String keyBase32) {
  keyBase32 = keyBase32.trim();
  if (keyBase32.isEmpty) {
    return Failure(err: "key不能为空");
  }

  keyBase32 = keyBase32.replaceAll(r'=', "");
  keyBase32 = keyBase32.toUpperCase();

  try {
    final keyDecoded = base32.decode(keyBase32);
    final keyReEncode = base32.encode(keyDecoded).replaceAll(r'=', "");

    if (keyBase32 != keyReEncode) {
      // base32编码noPadding模式会忽略最后一组[1,3,6]个字符（返回空数组）
      throw "往返校验失败";
    }
  } catch (e) {
    return Failure(err: "key:'$keyBase32'不是有效的base32字符串，错误信息：${e.toString()}");
  }

  return Success(data: keyBase32);
}
