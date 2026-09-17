import 'package:flutter_test/flutter_test.dart';
import 'package:totp/dart/result.dart';
import 'package:totp/dart/scan_str.dart';

const String k1 = 'NVQXE2LPNVQXE2L2';

String? scanned(String input) {
  final Result<String> res = isValidScanStr(input);
  return res is Success<String> ? res.data : null;
}

String? errorOf(String input) {
  final Result<String> res = isValidScanStr(input);
  return res is Failure<String> ? res.err : null;
}

void main() {
  group('扫码内容：直接是密钥', () {
    test('合法密钥', () {
      expect(scanned(k1), k1);
    });

    test('小写密钥会被规范化', () {
      expect(scanned('nvqxe2lp'), 'NVQXE2LP');
    });

    test('带 = 填充的密钥', () {
      expect(scanned('MZXW6==='), 'MZXW6');
    });

    test('非法密钥 → Failure', () {
      expect(errorOf('NVQXE2'), isNotNull);
      expect(errorOf('hello world'), isNotNull);
      expect(errorOf(''), isNotNull);
    });
  });

  group('扫码内容：otpauth://totp', () {
    test('secret 是第一个参数', () {
      expect(
        scanned('otpauth://totp/GitHub:me?secret=JBSWY3DPEHPK3PXP&issuer=GitHub'),
        'JBSWY3DPEHPK3PXP',
      );
    });

    test('secret 不是第一个参数（之前用 \\?secret= 会漏掉）', () {
      expect(
        scanned('otpauth://totp/GitHub:me?issuer=GitHub&secret=JBSWY3DPEHPK3PXP'),
        'JBSWY3DPEHPK3PXP',
      );
      expect(
        scanned('otpauth://totp/x?foo=1&bar=2&secret=$k1'),
        k1,
      );
    });

    test('secret 带 = 填充', () {
      expect(scanned('otpauth://totp/x?secret=MZXW6==='), 'MZXW6');
    });

    test('没有 secret 参数 → Failure', () {
      expect(errorOf('otpauth://totp/x?issuer=GitHub'), isNotNull);
      expect(errorOf('otpauth://totp/'), isNotNull);
    });

    test('hotp 不支持 → Failure', () {
      expect(
        errorOf('otpauth://hotp/x?secret=JBSWY3DPEHPK3PXP&counter=1'),
        isNotNull,
      );
    });
  });

  test('失败信息统一带上前缀', () {
    expect(errorOf('hello world'), startsWith('无效的TOTP key'));
  });
}
