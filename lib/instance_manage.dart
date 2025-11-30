import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:totp/theme.dart';
import 'package:totp/model/totp_key.dart';
import 'package:totp/model/totp_key_list.dart';
import 'package:totp/widgets/app_bar.dart';
import 'package:totp/widgets/dialog_operate_instance.dart';

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
              onPressed: () => showDialog(
                context: context,
                builder: (context) =>
                    OperateInstanceDialog(operate: Operate.create),
              ),
              child: Text("新增"),
            ),
            SizedBox(height: 20),
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
    res.add(_KeyInstance(keyIns: list[i], index: i));
  }

  return res;
}

class _KeyInstance extends StatefulWidget {
  const _KeyInstance({required this.keyIns, required this.index});

  final TOTPKey keyIns;
  final int index;

  @override
  State<_KeyInstance> createState() => _KeyInstanceState();
}

class _KeyInstanceState extends State<_KeyInstance> {
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
            _displayKeyInstance(),
            Spacer(),
            Column(
              children: [
                _ModifyButton(keyIns: widget.keyIns),
                _ReOrderButton(keyStr: widget.keyIns.key, index: widget.index),
                _DeleteButton(keyStr: widget.keyIns.key),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _displayKeyInstance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("> item ${widget.index}:", style: blackText(-2)),
        SizedBox(
          width: 160, // for auto wrap
          child: Text("key: ${widget.keyIns.key}", style: blackText(-2)),
        ),
        Text("name: ${widget.keyIns.name}", style: blackText(-2)),
        Text("autoActive: ${widget.keyIns.autoActive}", style: blackText(-2)),
        Text("isDeleted: ${widget.keyIns.isDeleted}", style: blackText(-2)),
      ],
    );
  }
}

class _ModifyButton extends StatelessWidget {
  const _ModifyButton({required this.keyIns});

  final TOTPKey keyIns;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showDialog(
        context: context,
        builder: (context) =>
            OperateInstanceDialog(operate: Operate.edit, keyIns: keyIns),
      ),
      child: Text("编辑", style: blackText(-2)),
    );
  }
}

class _ReOrderButton extends StatefulWidget {
  const _ReOrderButton({required this.keyStr, required this.index});

  final String keyStr;
  final int index;

  @override
  State<_ReOrderButton> createState() => _ReOrderButtonState();
}

class _ReOrderButtonState extends State<_ReOrderButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Padding(
            padding: EdgeInsets.only(top: 40, bottom: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _reOrderButton("移动到开头", 0),
                SizedBox(height: 20),
                _reOrderButton("向前移动一个", widget.index - 1),
                SizedBox(height: 20),
                _reOrderButton("向后移动一个", widget.index + 1),
                SizedBox(height: 20),
                _reOrderButton("移动到末尾", TOTPKeyList().list.length),
              ],
            ),
          ),
        ),
      ),
      child: Text("排序", style: blackText(-2)),
    );
  }

  Widget _reOrderButton(String text, int index) {
    return ElevatedButton(
      onPressed: () {
        TOTPKeyList().reOrder(widget.keyStr, index);
        Navigator.of(context).pop(); // 因为要在这里用context，所以widget用有状态的
      },
      child: Text(text),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.keyStr});

  final String keyStr;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("删除密钥实例", style: blackText(1)),
          content: Text(
            "本次删除不可恢复，请确认是否删除密钥为：$keyStr的实例?",
            style: blackText(-1),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("取消", style: greyText(-1)),
            ),
            TextButton(
              onPressed: () {
                TOTPKeyList().deleteHard(keyStr);
                Navigator.of(context).pop();
              },
              child: Text("确认", style: blackText(-1)),
            ),
          ],
        ),
      ),
      child: Text("删除", style: blackText(-2)),
    );
  }
}
