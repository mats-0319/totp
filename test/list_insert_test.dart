import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Test generate totp.", () async {
    List<int> l = [1,2,3,4];
    l.insert(4, 5);

    print("$l"); // use 'insert' as 'push' is ok
  });
}
