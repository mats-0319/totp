import 'package:flutter_test/flutter_test.dart';
import 'package:otp/otp.dart';
import 'package:totp/dart/result.dart';
import "package:totp/dart/totp.dart";

void main() {
  test("Test generate totp.", () async {
    final String key = "JBSWY3DPEHPK3PXP";
    var res = generateTOTP(key);
    expect(res is Success, true);

    List<String> l = [];
    int timestamp = DateTime.now().millisecondsSinceEpoch - 30_000;
    for (var i = 0; i < 3; i++) {
      l.add(
        OTP.generateTOTPCodeString(
          key,
          timestamp + i * 30_000,
          algorithm: Algorithm.SHA1,
          isGoogle: true,
        ),
      );
    }

    expect(contains(l, (res as Success).data), true);
  });
}

bool contains(List<String> l, String s) {
  bool containsFlag = false;
  for (var item in l) {
    if (item == s) {
      containsFlag = true;
      break;
    }
  }

  return containsFlag;
}
