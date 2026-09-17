import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:totp/model/totp_key_list.dart';

/// 测试环境：
///
/// - 把 path_provider 的目录换成临时目录（真机上是应用专属外部存储）；
/// - 把 `android_keystore` 通道换成"恒等变换"的假实现，并支持注入失败；
/// - 提供单例 [TOTPKeyList] 的重置入口，保证用例之间互不影响。
class TestEnv {
  TestEnv._(this.dir);

  /// 模拟的存储目录
  final Directory dir;

  /// 置 true 后 encrypt 会报错，用于测试"写盘失败"
  bool failEncrypt = false;

  /// 置 true 后 decrypt 会报错，用于测试"解密失败"
  bool failDecrypt = false;

  static const MethodChannel _keystoreChannel = MethodChannel(
    'android_keystore',
  );

  static Future<TestEnv> setUp() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final Directory dir = await Directory.systemTemp.createTemp('totp_test_');
    final TestEnv env = TestEnv._(dir);

    // 真机上是 PathProviderAndroid；测试里直接替换平台实现
    PathProviderPlatform.instance = _TempPathProvider(dir.path);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_keystoreChannel, env._onKeystoreCall);

    env.reset();
    return env;
  }

  Future<Object?> _onKeystoreCall(MethodCall call) async {
    switch (call.method) {
      case 'createKey':
        return null;
      case 'encrypt':
        if (failEncrypt) {
          throw PlatformException(
            code: 'KeyStore_Error',
            message: 'mock encrypt failure',
          );
        }
        return call.arguments as Uint8List;
      case 'decrypt':
        if (failDecrypt) {
          throw PlatformException(
            code: 'KeyStore_Error',
            message: 'mock decrypt failure',
          );
        }
        return call.arguments as Uint8List;
    }
    return null;
  }

  TOTPKeyList get keys => TOTPKeyList();

  /// 加密存储文件
  File get storeFile => File('${dir.path}/totp_key.txt');

  /// 明文导出文件
  File get exportFile => File('${dir.path}/totp_key.json');

  /// 解密失败时生成的备份文件
  List<File> get backupFiles => dir
      .listSync()
      .whereType<File>()
      .where((File f) => f.path.contains('totp_key.txt.'))
      .toList();

  void reset() {
    keys.list = [];
    keys.err = '';
  }

  Future<void> tearDown() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_keystoreChannel, null);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}

class _TempPathProvider extends PathProviderPlatform {
  _TempPathProvider(this.root);

  final String root;

  @override
  Future<String?> getExternalStoragePath() async => root;

  @override
  Future<String?> getApplicationDocumentsPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getTemporaryPath() async => root;
}
