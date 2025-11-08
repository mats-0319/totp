import 'package:flutter_test/flutter_test.dart';
import 'package:otp/otp.dart';

void main() {
  test("Test generate totp.", () async {
    print(
      OTP.generateTOTPCodeString(
        "JBSWY3DPEHPK3PXP",
        DateTime.now().millisecondsSinceEpoch,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
      ),
    );
    print(OTP.remainingSeconds());
  });
}
