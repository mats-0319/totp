import 'package:flutter_test/flutter_test.dart';
import 'package:otp/otp.dart';
import 'package:totp/dart/result.dart';
import "package:totp/dart/totp.dart";

void main() {
  test("Test generate totp.", () async {
    final String key = "JBSWY3DPEHPK3PXP";
    var res = generateTOTP(key);
    expect(res is Success, true);

    expect(
      (res as Success).data,
      OTP.generateTOTPCodeString(
        key,
        DateTime.now().millisecondsSinceEpoch,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
      ),
    );
  });
}
