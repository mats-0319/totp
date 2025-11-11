import 'package:flutter_test/flutter_test.dart';
import 'package:otp/otp.dart';
import "package:totp/dart/totp.dart";

void main() {
  test("Test generate totp.", () async {
    final String key = "JBSWY3DPEHPK3PXP";
    var (totp, _) = generateTOTP(key);

    expect(
      totp,
      OTP.generateTOTPCodeString(
        key,
        DateTime.now().millisecondsSinceEpoch,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
      ),
    );
  });
}
