import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totp/dart/result.dart';
import 'package:totp/model/export.dart';
import 'package:totp/model/totp_key.dart';
import 'package:totp/model/totp_key_list.dart';
import 'package:totp/widgets/app_bar.dart';
import 'package:totp/widgets/dialog_instance.dart';

class InstanceManagePage extends StatefulWidget {
  const InstanceManagePage({super.key});

  @override
  State<InstanceManagePage> createState() => _InstanceManagePageState();
}

class _InstanceManagePageState extends State<InstanceManagePage> {
  @override
  Widget build(BuildContext context) {
    var dataState = context.watch<TOTPKeyList>();

    return Scaffold(
      appBar: subpageAppBar(context, "实例管理"),
      body: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _functionBar(context),
            Expanded(
              child: ReorderableListView(
                onReorderItem: (oldIndex, newIndex) async {
                  setState(() {
                    // 程序已经可以自动处理删除后索引变化问题了，不需要再手动判断索引和-1
                    final item = dataState.list.removeAt(oldIndex);
                    dataState.list.insert(newIndex, item);
                  });

                  await TOTPKeyList().synchronized(() {
                    final item = dataState.list.removeAt(newIndex);
                    dataState.list.insert(oldIndex, item);
                  });
                },
                children: _displayKeyList(context, dataState.list),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _functionBar(BuildContext context) {
  final theme = Theme.of(context);

  return Container(
    margin: EdgeInsets.only(bottom: 20),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(
      color: theme.colorScheme.onSurface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        ElevatedButton(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => OperateDialog(
              operate: OperateE.create,
              keyIns: TOTPKey.empty(),
            ),
          ),
          child: Text(OperateE.create.text, style: theme.textTheme.labelMedium),
        ),
        Spacer(),
        ElevatedButton(
          onPressed: () async {
            final res = await export(TOTPKeyList());
            if (context.mounted && res is Success) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(content: Text("导出成功")),
              );
            }
          },
          child: Text("导出", style: theme.textTheme.labelMedium),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: () async {
            var res = await import(TOTPKeyList());
            if (context.mounted && res is Failure && res.err.isNotEmpty) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(content: Text(res.err)),
              );
            }
          },
          child: Text("导入", style: theme.textTheme.labelMedium),
        ),
      ],
    ),
  );
}

List<Widget> _displayKeyList(BuildContext context, List<TOTPKey> list) {
  final theme = Theme.of(context);

  return list.map((item) {
    return Container(
      key: ValueKey(item.key),
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadiusGeometry.circular(20),
        color: theme.colorScheme.onSurface,
      ),
      child: Row(
        children: [_details(context, item), Spacer(), _operates(context, item)],
      ),
    );
  }).toList();
}

Widget _details(BuildContext context, TOTPKey keyIns) {
  final theme = Theme.of(context);

  return SizedBox(
    width: 180,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "name: ${keyIns.name}",
          style: theme.textTheme.labelMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          "key: ${keyIns.key}",
          style: theme.textTheme.labelMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          "autoActive: ${keyIns.autoActive}",
          style: theme.textTheme.labelMedium,
        ),
        Text(
          "isDeleted: ${keyIns.isDeleted}",
          style: theme.textTheme.labelMedium,
        ),
      ],
    ),
  );
}

Widget _operates(BuildContext context, TOTPKey keyIns) {
  final theme = Theme.of(context);

  return Column(
    children: [
      ElevatedButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) =>
              OperateDialog(operate: OperateE.edit, keyIns: keyIns),
        ),
        child: Text(OperateE.edit.text, style: theme.textTheme.labelMedium),
      ),
      ElevatedButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("删除密钥实例", style: theme.textTheme.labelLarge),
            content: Text(
              "本次删除不可恢复，请确认是否删除密钥为：'${keyIns.key}'的实例?",
              style: theme.textTheme.labelLarge,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("取消", style: theme.textTheme.displayLarge),
              ),
              TextButton(
                onPressed: () async {
                  await TOTPKeyList().deleteHard(keyIns.key);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text("确认", style: theme.textTheme.labelLarge),
              ),
            ],
          ),
        ),
        child: Text("删除", style: theme.textTheme.labelMedium),
      ),
    ],
  );
}
