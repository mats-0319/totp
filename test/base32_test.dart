import 'package:base32/base32.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Test base32.", () async {
    final String key = "NVQXE2";

    expect(base32.decode(key), []); // x
  });
}
