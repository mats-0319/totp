import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:totp/model/totp_key.dart';
import 'package:totp/model/totp_key_list.dart';
import 'package:totp/pages/home.dart';
import 'package:totp/theme.dart';

const String k1 = 'NVQXE2LPNVQXE2L2';
const String k2 = 'NVQXE2LPNVQXE2L3';

Future<void> pumpHome(WidgetTester tester) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<TOTPKeyList>.value(
      value: TOTPKeyList(),
      child: MaterialApp(theme: defaultThemeData(), home: const HomePage()),
    ),
  );
}

bool hasCode(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text))
      .any((Text t) => t.data != null && t.data!.length == 6 && int.tryParse(t.data!) != null);
}

void main() {
  tearDown(() {
    TOTPKeyList()
      ..list = []
      ..err = '';
  });

  testWidgets('被隐藏的实例不出现在主页', (WidgetTester tester) async {
    TOTPKeyList().list = <TOTPKey>[
      TOTPKey('可见实例', k1, false),
      TOTPKey('隐藏实例', k2, true)..isDeleted = true,
    ];

    await pumpHome(tester);

    expect(find.text('可见实例'), findsOneWidget);
    expect(find.text('隐藏实例'), findsNothing);
  });

  testWidgets('err 非空时在主页展示错误信息', (WidgetTester tester) async {
    TOTPKeyList()
      ..list = []
      ..err = '存储读取失败';

    await pumpHome(tester);

    expect(find.text('存储读取失败'), findsOneWidget);
  });

  testWidgets('静默实例点激活后开始显示验证码', (WidgetTester tester) async {
    TOTPKeyList().list = <TOTPKey>[TOTPKey('实例', k1, false)];

    await pumpHome(tester);

    expect(find.text('激活'), findsOneWidget);
    expect(hasCode(tester), isFalse);

    await tester.tap(find.text('激活'));
    await tester.pump();

    expect(find.text('静默'), findsOneWidget);
    expect(hasCode(tester), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('autoActive 的实例一进来就是活跃状态', (WidgetTester tester) async {
    TOTPKeyList().list = <TOTPKey>[TOTPKey('实例', k1, true)];

    await pumpHome(tester);

    expect(find.text('静默'), findsOneWidget);
    expect(hasCode(tester), isTrue);
  });
}
