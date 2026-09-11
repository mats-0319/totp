import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totp/components/key_instance_active.dart';
import 'package:totp/model/totp_key.dart';

void main() {
  testWidgets("活动实例挂载后第一帧就能显示验证码，且不抛异常", (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActiveKeyInstance(
            keyIns: TOTPKey("NVQXE2LPNVQXE2LP", "demo", true),
            emitStatus: (bool flag) {},
          ),
        ),
      ),
    );

    // 回归用例：totpCode 曾经是未初始化的 late 字段，
    // 第一帧 build 读它就会抛 LateInitializationError 导致启动崩溃
    final bool hasCode = tester
        .widgetList<Text>(find.byType(Text))
        .any((Text t) => int.tryParse(t.data ?? "") != null);
    expect(hasCode, isTrue, reason: "第一帧就应该展示 6 位验证码");

    expect(tester.takeException(), isNull);

    // 走几个定时器周期，确认周期刷新不抛异常
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);

    // 卸载，触发 dispose 取消定时器
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
