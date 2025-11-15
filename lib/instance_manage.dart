import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totp/widgets/app_bar.dart';
import 'package:totp/widgets/dialog_create.dart';
import 'package:totp/widgets/key_item_silent.dart';

import 'model/totp_key.dart';
import 'model/totp_key_list.dart';
import 'widgets/dialog_modify.dart';

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
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => CreateDialog(),
                );
              },
              child: Text("新增"),
            ),
            Expanded(
              child: ListView(children: _displayKeyList(dataState.list)),
            ),
          ],
        ),
      ),
    );
  }
}

List<Widget> _displayKeyList(List<TOTPKey> list) {
  List<Widget> res = [];

  for (var i = 0; i < list.length; i++) {
    res.add(_KeyItem(keyIns: list[i], index: i));
  }

  return res;
}

class _KeyItem extends StatefulWidget {
  const _KeyItem({required this.keyIns, required this.index});

  final TOTPKey keyIns;
  final int index;

  @override
  State<_KeyItem> createState() => _KeyItemState();
}

class _KeyItemState extends State<_KeyItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadiusGeometry.circular(20),
        color: Theme.of(context).colorScheme.onSurface,
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: Row(
          children: [
            Text(
              _displayKeyInList(widget.keyIns, widget.index),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Spacer(),
            Column(
              children: [
                _ModifyButton(keyIns: widget.keyIns),
                _DeleteButton(keyStr: widget.keyIns.key),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _displayKeyInList(TOTPKey keyIns, int index) {
  return "> item $index: \n"
      "key: ${keyIns.key},\n"
      "name: ${keyIns.name},\n"
      "autoActive: ${keyIns.autoActive},\n"
      "isDeleted: ${keyIns.isDeleted},\n";
}

class _ModifyButton extends StatelessWidget {
  const _ModifyButton({required this.keyIns});

  final TOTPKey keyIns;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => ModifyDialog(isReadonly: false, keyIns: keyIns),
        );
      },
      child: Text("编辑", style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.keyStr});

  final String keyStr;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("删除密钥实例"),
            content: Text("本次删除不可恢复，请确认是否删除密钥为：$keyStr的实例?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("取消"),
              ),
              TextButton(
                onPressed: () async {
                  await TOTPKeyList().deleteHard(keyStr);
                  Navigator.of(context).pop();
                },
                child: Text("确认"),
              ),
            ],
          ),
        );
      },
      child: Text("删除", style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}
