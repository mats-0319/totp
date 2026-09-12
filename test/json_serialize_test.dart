import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Test str RE", () {
    String s = "otpauth://totp/Github:author_name?secret=ABCDEF&issuer=Github";

    expect(s.startsWith("otpauth://totp/"), true);

    RegExp re = RegExp(r'\?secret=(\w+)');
    RegExpMatch? matchNullable = re.firstMatch(s);
    if (matchNullable == null) {
      expect(true, false);
    }

    RegExpMatch match = matchNullable!;

    // match.groupCount 表示捕获的组的数量
    for (int i = 0; i <= match.groupCount; i++) {
      final String m = match.group(i)!;
      print("i: $i, v: $m");
    }
  });
}
