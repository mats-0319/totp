import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totp/model/totp_key.dart';
import 'package:totp/theme.dart';
import 'package:totp/widgets/key_instance_active.dart';
import 'package:totp/widgets/key_instance_silent.dart';

const String k1 = 'NVQXE2LPNVQXE2L2';

/// 页面里当前显示的 6 位验证码；没有就返回 null
String? shownCode(WidgetTester tester) {
  for (final Text text in tester.widgetList<Text>(find.byType(Text))) {
    final String? data = text.data;
    if (data != null && data.length == 6 && int.tryParse(data) != null) {
      return data;
    }
  }
  return null;
}

void main() {
  testWidgets('挂载后第一帧就显示 6 位验证码', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: defaultThemeData(),
        home: Scaffold(
          body: ActiveKeyInstance(
            keyIns: TOTPKey('实例', k1, true),
            onChanged: (bool _) {},
          ),
        ),
      ),
    );

    // 回归点：以前 totpCode 是未初始化的 late 字段，第一帧 build 就抛 LateInitializationError
    expect(shownCode(tester), isNotNull);
    expect(tester.takeException(), isNull);

    // 走几个定时器周期
    await tester.pump(const Duration(milliseconds: 300));
    expect(shownCode(tester), isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('点静默后组件被移除，定时器随 dispose 一起取消', (WidgetTester tester) async {
    bool active = true;
    final TOTPKey key = TOTPKey('实例', k1, true);

    await tester.pumpWidget(
      MaterialApp(
        theme: defaultThemeData(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              void onChange(bool value) => setState(() => active = value);
              return active
                  ? ActiveKeyInstance(keyIns: key, onChanged: onChange)
                  : SilentKeyInstance(keyIns: key, onChanged: onChange);
            },
          ),
        ),
      ),
    );

    expect(find.byType(ActiveKeyInstance), findsOneWidget);

    await tester.tap(find.text('静默'));
    await tester.pump();

    expect(find.byType(ActiveKeyInstance), findsNothing);
    expect(find.byType(SilentKeyInstance), findsOneWidget);

    // 定时器如果没被取消，测试结束时会报 "A Timer is still pending"
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });

  testWidgets('非法 key：回调 false 退回静默，且不抛异常', (WidgetTester tester) async {
    bool? received;

    await tester.pumpWidget(
      MaterialApp(
        theme: defaultThemeData(),
        home: Scaffold(
          body: ActiveKeyInstance(
            keyIns: TOTPKey('坏实例', 'NVQXE2', true),
            onChanged: (bool value) => received = value,
          ),
        ),
      ),
    );

    expect(received, isFalse);
    expect(shownCode(tester), isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('切换 key 后显示新 key 的验证码', (WidgetTester tester) async {
    const String k2 = 'NVQXE2LPNVQXE2L3';
    String current = k1;

    await tester.pumpWidget(
      MaterialApp(
        theme: defaultThemeData(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: <Widget>[
                  ActiveKeyInstance(
                    keyIns: TOTPKey('实例', current, true),
                    onChanged: (bool _) {},
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => current = k2),
                    child: const Text('换 key'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('换 key'));
    await tester.pump();

    expect(shownCode(tester), isNotNull);
    expect(tester.takeException(), isNull);
  });
}
