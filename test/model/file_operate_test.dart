import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:totp/dart/result.dart';
import 'package:totp/model/file_operate.dart';
import 'package:totp/model/totp_key.dart';

import '../helpers/test_env.dart';

const String k1 = 'NVQXE2LPNVQXE2L2';

void main() {
  late TestEnv env;

  setUp(() async {
    env = await TestEnv.setUp();
  });

  tearDown(() async {
    await env.tearDown();
  });

  group('export', () {
    test('把当前列表以明文 json 写到 totp_key.json', () async {
      await env.keys.create(TOTPKey('n1', k1, false));

      final Result<String> res = await export(env.keys);

      expect(res, isA<Success<String>>());
      expect((res as Success<String>).data, env.exportFile.path);
      final List<dynamic> decoded =
          jsonDecode(await env.exportFile.readAsString()) as List<dynamic>;
      expect(decoded.length, 1);
      expect((decoded.first as Map<String, dynamic>)['key'], k1);
    });

    test('导出文件与加密存储文件是两个文件', () async {
      await env.keys.create(TOTPKey('n1', k1, false));

      await export(env.keys);

      expect(env.exportFile.path, isNot(env.storeFile.path));
      expect(await env.storeFile.exists(), isTrue);
      expect(await env.exportFile.exists(), isTrue);
    });
  });

  group('import', () {
    test('从导出文件恢复整个列表', () async {
      await env.keys.create(TOTPKey('n1', k1, false));
      await export(env.keys);
      env.reset();

      final Result<void> res = await import(env.keys);

      expect(res, isA<Success<void>>());
      expect(env.keys.list.length, 1);
      expect(env.keys.list.first.key, k1);
      expect(env.keys.list.first.name, 'n1');
    });

    test('文件不存在：返回 Failure', () async {
      final Result<void> res = await import(env.keys);

      expect(res, isA<Failure<void>>());
    });

    test('内容不是 json：返回 Failure 且不动现有列表', () async {
      await env.keys.create(TOTPKey('n1', k1, false));
      await env.exportFile.writeAsString('not a json');

      final Result<void> res = await import(env.keys);

      expect(res, isA<Failure<void>>());
      expect(env.keys.list.length, 1);
      expect(env.keys.list.first.key, k1);
    });

    test('内容里有非法 key：返回 Failure 且不动现有列表', () async {
      await env.keys.create(TOTPKey('n1', k1, false));
      await env.exportFile.writeAsString(
        jsonEncode(<Map<String, dynamic>>[
          <String, dynamic>{
            'name': 'bad',
            'key': 'NVQXE2',
            'autoActive': false,
            'isDeleted': false,
          },
        ]),
      );

      final Result<void> res = await import(env.keys);

      expect(res, isA<Failure<void>>());
      expect(env.keys.list.length, 1);
      expect(env.keys.list.first.key, k1);
    });
  });
}
