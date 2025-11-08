import "dart:convert";
import "package:test/test.dart";
import "package:totp/model/totp_key.dart";

void main() {
  test("Test totp key instance (de)serialize.", () {
    TOTPKey totpKeyIns = TOTPKey("a totp key", "a totp pwd name", true);
    expect(jsonEncode(totpKeyIns),
        '{"key":"a totp key","name":"a totp pwd name","autoActive":true,"isDeleted":false}');

    var totpKeyJson = jsonDecode('{"key":"a totp key","name":"a totp pwd name","autoActive":true,"isDeleted":false}') as Map<String, dynamic>;
    TOTPKey totpKeyInsFromJson = TOTPKey.fromJson(totpKeyJson);
    expect(json.encode(totpKeyInsFromJson),
        '{"key":"a totp key","name":"a totp pwd name","autoActive":true,"isDeleted":false}');
  });

  test("Test totp key instance list (de)serialize.", () {
    List<TOTPKey> listIns = [];
    listIns.add(TOTPKey("key1", "name1", true));
    listIns.add(TOTPKey("key2", "name2", false));

    String jsonStr = jsonEncode(listIns);
    // print(jsonStr);
    // output: [{"key":"key1","name":"name1","autoActive":true,"isDeleted":false},
    //         {"key":"key2","name":"name2","autoActive":false,"isDeleted":false}]

    List<dynamic> parsedJson = jsonDecode(jsonStr);

    listIns = [];
    expect(listIns.length, 0);

    for (var value in parsedJson) {
      listIns.add(TOTPKey.fromJson(value));
    }
    expect(listIns.length, 2);
  });
}
