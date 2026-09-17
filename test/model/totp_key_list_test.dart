import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:totp/dart/result.dart';
import 'package:totp/model/totp_key.dart';

import '../helpers/test_env.dart';

const String k1 = 'NVQXE2LPNVQXE2L2';
const String k2 = 'NVQXE2LPNVQXE2L3';

void main() {
  late TestEnv env;

  setUp(() async {
    env = await TestEnv.setUp();
  });

  tearDown(() async {
    await env.tearDown();
  });

  Future<List<dynamic>> readStore() async {
    return jsonDecode(await env.storeFile.readAsString()) as List<dynamic>;
  }

  group('create', () {
    test('成功：写入列表并落盘', () async {
      final Result<void> res = await env.keys.create(
        TOTPKey('n1', k1, false),
      );

      expect(res, isA<Success<void>>());
      expect(env.keys.list.length, 1);
      expect(await env.storeFile.exists(), isTrue);
      final List<dynamic> stored = await readStore();
      expect(stored.length, 1);
      expect((stored.first as Map<String, dynamic>)['key'], k1);
      expect(env.keys.err, '');
    });

    test('重复 key：返回 Failure 且列表不变', () async {
      await env.keys.create(TOTPKey('n1', k1, false));

      final Result<void> res = await env.keys.create(
        TOTPKey('n2', k1, true),
      );

      expect(res, isA<Failure<void>>());
      expect((res as Failure<void>).err, contains('Duplicate'));
      expect(env.keys.list.length, 1);
      expect((await readStore()).length, 1);
    });

    test('非法 key：返回 Failure 且不落盘', () async {
      final Result<void> res = await env.keys.create(
        TOTPKey('n1', 'NVQXE2', false), // 长度余数 6，往返校验不过
      );

      expect(res, isA<Failure<void>>());
      expect(env.keys.list, isEmpty);
      expect(await env.storeFile.exists(), isFalse);
    });

    test('写盘失败：返回 Failure，列表回滚，且不通知监听者', () async {
      int notified = 0;
      void listener() => notified++;
      env.keys.addListener(listener);
      env.failEncrypt = true;

      final Result<void> res = await env.keys.create(
        TOTPKey('n1', k1, false),
      );

      expect(res, isA<Failure<void>>());
      expect(env.keys.list, isEmpty);
      expect(notified, 0);
      env.keys.removeListener(listener);
    });
  });

  group('update', () {
    test('改名称：成功并落盘', () async {
      await env.keys.create(TOTPKey('old', k1, false));
      final TOTPKey item = env.keys.list.first;
      item.name = 'new';

      final Result<void> res = await env.keys.update(item);

      expect(res, isA<Success<void>>());
      final List<dynamic> stored = await readStore();
      expect((stored.first as Map<String, dynamic>)['name'], 'new');
    });

    test('改成别人的 key：返回 Failure 且文件保持原样', () async {
      await env.keys.create(TOTPKey('a', k1, false));
      await env.keys.create(TOTPKey('b', k2, false));
      final TOTPKey item = env.keys.list[1];
      item.key = k1;

      final Result<void> res = await env.keys.update(item);

      expect(res, isA<Failure<void>>());
      final List<dynamic> stored = await readStore();
      expect((stored[1] as Map<String, dynamic>)['key'], k2);
    });

    test('同一把 key 只改大小写：成功，并把规范形式写回', () async {
      await env.keys.create(TOTPKey('a', k1, false));
      final TOTPKey item = env.keys.list.first;
      item.key = k1.toLowerCase();

      final Result<void> res = await env.keys.update(item);

      expect(res, isA<Success<void>>());
      expect(item.key, k1);
      final List<dynamic> stored = await readStore();
      expect((stored.first as Map<String, dynamic>)['key'], k1);
    });
  });

  group('deleteHard', () {
    test('key 不存在：返回 Success 且不写盘', () async {
      await env.keys.create(TOTPKey('a', k1, false));
      final String before = await env.storeFile.readAsString();

      final Result<void> res = await env.keys.deleteHard('NOT_EXIST_KEY');

      expect(res, isA<Success<void>>());
      expect(env.keys.list.length, 1);
      expect(await env.storeFile.readAsString(), before);
    });

    test('写盘失败：元素恢复到原下标', () async {
      await env.keys.create(TOTPKey('a', k1, false));
      await env.keys.create(TOTPKey('b', k2, false));
      env.failEncrypt = true;

      final Result<void> res = await env.keys.deleteHard(k1);

      expect(res, isA<Failure<void>>());
      expect(env.keys.list.length, 2);
      expect(env.keys.list.first.key, k1);
      expect(env.keys.list[1].key, k2);
    });
  });

  group('createList', () {
    test('含重复 key：整体回滚，文件不变', () async {
      await env.keys.create(TOTPKey('a', k1, false));
      final String before = await env.storeFile.readAsString();

      final Result<void> res = await env.keys.createList(<TOTPKey>[
        TOTPKey('b', k2, false),
        TOTPKey('c', k2, true),
      ]);

      expect(res, isA<Failure<void>>());
      expect(env.keys.list.length, 1);
      expect(env.keys.list.first.key, k1);
      expect(await env.storeFile.readAsString(), before);
    });

    test('含非法 key：整体回滚', () async {
      await env.keys.create(TOTPKey('a', k1, false));

      final Result<void> res = await env.keys.createList(<TOTPKey>[
        TOTPKey('b', k2, false),
        TOTPKey('c', 'ABC', false),
      ]);

      expect(res, isA<Failure<void>>());
      expect(env.keys.list.length, 1);
      expect(env.keys.list.first.key, k1);
    });

    test('空列表：清空并落盘', () async {
      await env.keys.create(TOTPKey('a', k1, false));

      final Result<void> res = await env.keys.createList(<TOTPKey>[]);

      expect(res, isA<Success<void>>());
      expect(env.keys.list, isEmpty);
      expect(await readStore(), isEmpty);
    });
  });

  group('initialize', () {
    test('首次安装（没有存储文件）：播种两个示例实例', () async {
      await env.keys.initialize();

      expect(env.keys.err, '');
      expect(env.keys.list.length, 2);
      expect(await env.storeFile.exists(), isTrue);
    });

    test('已有存储：还原列表，不再播种示例', () async {
      await env.keys.create(TOTPKey('mine', k1, false));
      env.reset();

      await env.keys.initialize();

      expect(env.keys.err, '');
      expect(env.keys.list.length, 1);
      expect(env.keys.list.first.key, k1);
    });

    test('存储内容损坏：err 非空、列表为空、原文件不被覆盖', () async {
      final List<int> garbage = <int>[1, 2, 3, 4];
      await env.storeFile.writeAsBytes(garbage);

      await env.keys.initialize();

      expect(env.keys.err, isNotEmpty);
      expect(env.keys.list, isEmpty);
      expect(await env.storeFile.readAsBytes(), garbage);
    });

    test('解密失败：备份原文件、err 非空、通知监听者', () async {
      await env.keys.create(TOTPKey('mine', k1, false));
      env.reset();
      env.failDecrypt = true;

      int notified = 0;
      void listener() => notified++;
      env.keys.addListener(listener);

      await env.keys.initialize();

      expect(env.keys.err, isNotEmpty);
      expect(env.keys.list, isEmpty);
      expect(env.backupFiles.length, 1); // totp_key.txt.<ts>
      expect(await env.storeFile.exists(), isFalse); // 已被改名
      expect(notified, greaterThan(0));

      env.keys.removeListener(listener);
    });
  });
}
