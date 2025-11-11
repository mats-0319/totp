import "package:test/test.dart";
import "package:totp/model/totp_key.dart";
import "package:totp/model/totp_key_list.dart";

void main() {
  test("Test file persistence.", () async {
    List<TOTPKey> listIns = [];
    listIns.add(TOTPKey("key1", "name1", true));
    listIns.add(TOTPKey("key2", "name2", false));

    await write(listIns, true);

    listIns = [];
    expect(listIns.length, 0);
    listIns = await read(true);
    expect(listIns.length, 2);
  });
}
