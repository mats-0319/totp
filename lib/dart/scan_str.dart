import 'package:totp/dart/result.dart';
import 'package:totp/dart/totp.dart';

Result<String> isValidScanStr(String str) {
  // 'otpauth://' uri
  if (str.startsWith("otpauth://totp")) {
    RegExp re = RegExp(r'[?&]secret=(\w+)');
    final match = re.firstMatch(str);
    if (match != null) {
      str = match.group(1)!;
    }
  }

  // raw base32 key & key parsed from standard uri
  var res = normalize(str);
  if (res is Success) {
    return res;
  }

  return Failure(err: "无效的TOTP key：$str");
}
