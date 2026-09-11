import 'package:flutter/material.dart';
import "package:totp/components/dialog_components.dart";
import 'package:totp/dart/result.dart';
import 'package:totp/model/totp_key.dart';
import 'package:totp/model/totp_key_list.dart';
import 'package:totp/theme.dart';

enum OperateE {
  create(text: "创建"),
  modify(text: "修改"),
  edit(text: "编辑");

  const OperateE({required this.text});

  final String text;
}

class OperateDialog extends StatefulWidget {
  const OperateDialog({super.key, required this.operate, required this.keyIns});

  final OperateE operate;
  final TOTPKey keyIns;

  @override
  State<StatefulWidget> createState() => _OperateDialogState();
}

class _OperateDialogState extends State<OperateDialog> {
  late TOTPKey kc = TOTPKey.deepCopy(widget.keyIns);

  void _onNameChanged(String value) {
    setState(() {
      kc.name = value;
    });
  }

  void _onKeyChanged(String value) {
    setState(() {
      kc.key = value;
    });
  }

  void _onAutoActiveChanged(bool value) {
    setState(() {
      kc.autoActive = value;
    });
  }

  void _onIsDeletedChanged(bool value) {
    setState(() {
      kc.isDeleted = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.only(left: 20, right: 20),
      child: Padding(
        padding: EdgeInsets.only(top: 30, bottom: 20, left: 30, right: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${widget.operate.text}TOTP密钥实例", style: blackText(1)),
            SizedBox(height: 30),
            NameInput(defaultValue: kc.name, onChanged: _onNameChanged),
            SizedBox(height: 20),
            _keyInput(),
            SizedBox(height: 20),
            SwitchWithDescription(
              defaultValue: kc.autoActive,
              onChanged: _onAutoActiveChanged,
              title: "是否在启动时自动激活",
              trueStr: "自动激活",
              falseStr: "不自动激活",
            ),
            SizedBox(height: 10),
            ?_deleteWidget(),
            SizedBox(height: 10),
            ConfirmButton(text: widget.operate.text, func: _operateFunc),
          ],
        ),
      ),
    );
  }

  Widget _keyInput() {
    if (widget.operate == OperateE.modify) {
      return KeyInputReadonly(text: kc.key);
    } else {
      return KeyInput(defaultValue: kc.key, onChanged: _onKeyChanged);
    }
  }

  Widget? _deleteWidget() {
    if (widget.operate != OperateE.create) {
      return SwitchWithDescription(
        defaultValue: kc.isDeleted,
        onChanged: _onIsDeletedChanged,
        title: "是否在主页隐藏该密钥",
        trueStr: "隐藏",
        falseStr: "不隐藏",
      );
    }

    return null;
  }

  Future<Result<void>> _operateFunc() async {
    // 先备份原值，操作失败时回滚，避免校验失败后列表里留下未保存的“幽灵修改”
    final TOTPKey backup = TOTPKey.deepCopy(widget.keyIns);

    copyBack(widget.keyIns, kc);

    final Result<void> res = widget.operate == OperateE.create
        ? await TOTPKeyList().create(widget.keyIns)
        : await TOTPKeyList().update(widget.keyIns.key);

    if (res is Failure) {
      copyBack(widget.keyIns, backup);
    }

    return res;
  }
}
