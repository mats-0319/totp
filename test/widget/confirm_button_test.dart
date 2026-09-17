import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totp/dart/result.dart';
import 'package:totp/theme.dart';
import 'package:totp/widgets/dialog_components.dart';

/// 把 ConfirmButton 放进一个真正的弹窗里，方便断言"弹窗是否关闭"
Future<void> openConfirm(
  WidgetTester tester,
  Future<Result<void>> Function() func,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: defaultThemeData(),
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) => ElevatedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (BuildContext context) =>
                  ConfirmButton(text: '确定', func: func),
            ),
            child: const Text('打开'),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('打开'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('成功：关闭弹窗', (WidgetTester tester) async {
    await openConfirm(tester, () async => Success(data: null));
    expect(find.text('确定'), findsOneWidget);

    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    expect(find.text('确定'), findsNothing);
    expect(find.text('打开'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('失败：保留弹窗、显示错误、按钮恢复可点', (WidgetTester tester) async {
    int calls = 0;

    await openConfirm(tester, () async {
      calls++;
      return Failure(err: '写入失败');
    });

    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    expect(calls, 1);
    expect(find.text('写入失败'), findsOneWidget);
    expect(find.text('确定'), findsOneWidget); // 弹窗还在
    expect(find.byType(CircularProgressIndicator), findsNothing); // 没有卡在 loading

    // 关掉错误提示后，按钮可以再点（错误弹窗会挡住下面的按钮）
    Navigator.of(tester.element(find.byType(AlertDialog))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(calls, 2);
  });

  testWidgets('底层抛异常：也要弹错且按钮不卡死', (WidgetTester tester) async {
    int calls = 0;

    await openConfirm(tester, () async {
      calls++;
      throw PlatformException(code: 'KeyStore_Error', message: 'encrypt 失败');
    });

    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    expect(calls, 1);
    expect(find.textContaining('encrypt 失败'), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    Navigator.of(tester.element(find.byType(AlertDialog))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(calls, 2);
  });

  testWidgets('loading 期间重复点击只执行一次', (WidgetTester tester) async {
    int calls = 0;
    final Completer<Result<void>> completer = Completer<Result<void>>();

    await openConfirm(tester, () {
      calls++;
      return completer.future;
    });

    await tester.tap(find.text('确定'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 加载中再点一次（此时按钮内容是转圈，用类型定位）
    await tester.tap(find.byType(ConfirmButton), warnIfMissed: false);
    await tester.pump();
    expect(calls, 1);

    completer.complete(Success(data: null));
    await tester.pumpAndSettle();
    expect(find.text('确定'), findsNothing);
  });
}
