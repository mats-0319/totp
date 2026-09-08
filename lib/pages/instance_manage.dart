import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totp/components/dialog_create.dart';
import 'package:totp/components/dialog_edit.dart';
import 'package:totp/model/totp_key.dart';
import 'package:totp/model/totp_key_list.dart';
import 'package:totp/theme.dart';
import 'package:totp/widgets/app_bar.dart';

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
            SizedBox(height: 20),
            Expanded(
              child: ReorderableListView(
                shrinkWrap: true, // 防止expanded布局溢出错误
                onReorderItem: (oldIndex, newIndex) async {
                  setState(() {
                    // 程序已经可以自动处理删除后索引变化问题了，不需要再手动判断索引和-1
                    final item = dataState.list.removeAt(oldIndex);
                    dataState.list.insert(newIndex, item);
                  });

                  await TOTPKeyList().synchronized();
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
  return Row(
    children: [
      ElevatedButton(
        onPressed: () =>
            showDialog(context: context, builder: (context) => CreateDialog()),
        child: Text("新增"),
      ),
      Spacer(),
      ElevatedButton(
        onPressed: () async {
          final uri = await TOTPKeyList().export();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(content: Text("导出文件：$uri")),
          );
        },
        child: Text("导出"),
      ),
      SizedBox(width: 10),
      ElevatedButton(
        onPressed: () async {
          try {
            await TOTPKeyList().import();
          } catch (e) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(content: Text(e.toString())),
            );
          }
        },
        child: Text("导入"),
      ),
    ],
  );
}

List<Widget> _displayKeyList(BuildContext context, List<TOTPKey> list) {
  return list.map((item) {
    return Container(
      key: ValueKey(item.key),
      margin: EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadiusGeometry.circular(20),
        color: Theme.of(context).colorScheme.onSurface,
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: Row(
          children: [
            _details(context, item),
            Spacer(),
            _operates(context, item),
          ],
        ),
      ),
    );
  }).toList();
}

Widget _details(BuildContext context, TOTPKey keyIns) {
  return SizedBox(
    width: 180,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "name: ${keyIns.name}",
          style: blackText(-2),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          "key: ${keyIns.key}",
          style: blackText(-2),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text("autoActive: ${keyIns.autoActive}", style: blackText(-2)),
        Text("isDeleted: ${keyIns.isDeleted}", style: blackText(-2)),
      ],
    ),
  );
}

Widget _operates(BuildContext context, TOTPKey keyIns) {
  return Column(
    children: [
      ElevatedButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => EditDialog(keyIns: keyIns),
        ),
        child: Text("编辑", style: blackText(-2)),
      ),
      ElevatedButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("删除密钥实例", style: blackText(1)),
            content: Text(
              "本次删除不可恢复，请确认是否删除密钥为：'${keyIns.key}'的实例?",
              style: blackText(-1),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("取消", style: greyText(-1)),
              ),
              TextButton(
                onPressed: () {
                  TOTPKeyList().deleteHard(keyIns.key);
                  Navigator.of(context).pop();
                },
                child: Text("确认", style: blackText(-1)),
              ),
            ],
          ),
        ),
        child: Text("删除", style: blackText(-2)),
      ),
    ],
  );
}
