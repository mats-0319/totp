import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totp/model/totp_key.dart';
import 'package:totp/theme.dart';
import 'package:totp/widgets/dialog_instance.dart';

const String k1 = 'NVQXE2LPNVQXE2L2';

Future<void> pumpDialog(
  WidgetTester tester,
  OperateE operate,
  TOTPKey key,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: defaultThemeData(),
      home: Scaffold(body: OperateDialog(operate: operate, keyIns: key)),
    ),
  );
}

Iterable<TextField> disabledFields(WidgetTester tester) {
  return tester
      .widgetList<TextField>(find.byType(TextField))
      .where((TextField f) => f.enabled == false);
}

void main() {
  testWidgets('create：key 可编辑，没有"隐藏"开关', (WidgetTester tester) async {
    await pumpDialog(tester, OperateE.create, TOTPKey.empty());

    expect(find.widgetWithText(ElevatedButton, '创建'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(disabledFields(tester), isEmpty);
    expect(find.byType(Switch), findsOneWidget); // 只有"默认状态"
  });

  testWidgets('modify：key 只读，有"隐藏"开关', (WidgetTester tester) async {
    await pumpDialog(tester, OperateE.modify, TOTPKey('实例', k1, false));

    expect(find.widgetWithText(ElevatedButton, '修改'), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(2));
    expect(disabledFields(tester).length, 1);
  });

  testWidgets('edit：key 可编辑，有"隐藏"开关', (WidgetTester tester) async {
    await pumpDialog(tester, OperateE.edit, TOTPKey('实例', k1, false));

    expect(find.widgetWithText(ElevatedButton, '编辑'), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(2));
    expect(disabledFields(tester), isEmpty);
  });

  testWidgets('校验失败：弹错误提示，且列表里的对象回滚', (WidgetTester tester) async {
    final TOTPKey key = TOTPKey('原名', k1, false);
    await pumpDialog(tester, OperateE.edit, key);

    // 改名字 + 填一个非法 key
    await tester.enterText(find.byType(TextField).first, '新名字');
    await tester.enterText(find.byType(TextField).last, 'NVQXE2');
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, '编辑'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.textContaining('NVQXE2'),
      ),
      findsOneWidget,
    );
    // 幽灵修改：对话框里改坏的值不能留在原对象上
    expect(key.name, '原名');
    expect(key.key, k1);
  });
}
