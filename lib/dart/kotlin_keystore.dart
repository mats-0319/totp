import 'package:flutter/services.dart';
import 'package:totp/dart/result.dart';

class AndroidKeyStore {
  static const MethodChannel _channel = MethodChannel("android_keystore");

  static Future<Result<void>> createKey() async {
    try {
      await _channel.invokeMethod<void>("createKey");
      return Success(data: null);
    } catch (e) {
      return Failure(err: e.toString());
    }
  }

  static Future<Result<Uint8List>> encrypt(Uint8List data) async {
    try {
      final res = await _channel.invokeMethod<Uint8List>("encrypt", data);
      if (res == null) {
        throw "Encrypt failed";
      }

      return Success(data: res);
    } catch (e) {
      return Failure(err: e.toString());
    }
  }

  static Future<Result<Uint8List>> decrypt(Uint8List data) async {
    try {
      final res = await _channel.invokeMethod<Uint8List>("decrypt", data);
      if (res == null) {
        throw "Decrypt failed";
      }

      return Success(data: res);
    } catch (e) {
      return Failure(err: e.toString());
    }
  }
}
