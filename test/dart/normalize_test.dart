import 'package:flutter_test/flutter_test.dart';
import 'package:totp/dart/result.dart';
import 'package:totp/dart/totp.dart';

String? normalized(String input) {
  final Result<String> res = normalize(input);
  return res is Success<String> ? res.data : null;
}

String? errorOf(String input) {
  final Result<String> res = normalize(input);
  return res is Failure<String> ? res.err : null;
}

void main() {
  group('normalize 接受合法 base32', () {
    test('已经是规范形式时原样返回', () {
      expect(normalized('NVQXE2LPNVQXE2L2'), 'NVQXE2LPNVQXE2L2');
    });

    test('小写转成大写', () {
      expect(normalized('nvqxe2lp'), 'NVQXE2LP');
    });

    test('去掉填充的 =（带与不带填充都接受）', () {
      expect(normalized('MZXW6==='), 'MZXW6');
      expect(normalized('MZXW6'), 'MZXW6');
    });

    test('去掉前后空白', () {
      expect(normalized('  jbswy3dpehpk3pxp\n'), 'JBSWY3DPEHPK3PXP');
    });

    test('返回值一律是大写且不含 =', () {
      final String? value = normalized('  mzxw6===  ');
      expect(value, isNotNull);
      expect(value, isNot(contains('=')));
      expect(value, value!.toUpperCase());
    });
  });

  group('normalize 拒绝非法 base32', () {
    test('空串或纯空白', () {
      expect(errorOf(''), isNotNull);
      expect(errorOf('   '), isNotNull);
    });

    test('长度余数为 1/3/6：base32 会静默丢字符，必须被往返校验拦住', () {
      expect(errorOf('A'), isNotNull); // 1 个字符
      expect(errorOf('ABC'), isNotNull); // 3 个字符
      expect(errorOf('NVQXE2'), isNotNull); // 6 个字符
    });

    test('含非 base32 字符', () {
      expect(errorOf('0O1I'), isNotNull);
      expect(errorOf('JBSWY3DPEHPK3PX!'), isNotNull);
    });

    test('含内部空白', () {
      expect(errorOf('MZXW6 YTB'), isNotNull);
      expect(errorOf('JBSWY 3DPEHPK3PXP'), isNotNull);
    });

    test('失败信息里带上原始 key，便于排查', () {
      expect(errorOf('0O1I'), contains('0O1I'));
    });
  });
}
