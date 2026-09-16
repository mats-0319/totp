import 'package:flutter/material.dart';
import 'package:totp/dart/result.dart';
import 'package:totp/model/totp_key.dart';
import 'package:totp/model/totp_key_list.dart';
import "package:totp/widgets/dialog_components.dart";

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
    setState(() => kc.name = value);
  }

  void _onKeyChanged(String value) {
    setState(() => kc.key = value);
  }

  void _onAutoActiveChanged(bool value) {
    setState(() => kc.autoActive = value);
  }

  void _onIsDeletedChanged(bool value) {
    setState(() => kc.isDeleted = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${widget.operate.text}TOTP密钥实例",
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: 30),
            NameInput(defaultValue: kc.name, onChanged: _onNameChanged),
            SizedBox(height: 20),
            _keyInput(),
            SizedBox(height: 20),
            SwitchWithDescription(
              defaultValue: kc.autoActive,
              onChanged: _onAutoActiveChanged,
              title: "实例的默认状态",
              trueStr: "活跃状态",
              falseStr: "静默状态",
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
    return widget.operate == OperateE.modify
        ? KeyInputReadonly(text: kc.key)
        : KeyInput(defaultValue: kc.key, onChanged: _onKeyChanged);
  }

  Widget? _deleteWidget() {
    return widget.operate != OperateE.create
        ? SwitchWithDescription(
            defaultValue: kc.isDeleted,
            onChanged: _onIsDeletedChanged,
            title: "是否在主页隐藏该实例",
            trueStr: "隐藏",
            falseStr: "不隐藏",
          )
        : null;
  }

  Future<Result<void>> _operateFunc() async {
    final TOTPKey backup = TOTPKey.deepCopy(widget.keyIns);

    copyBack(widget.keyIns, kc);

    final Result<void> res = widget.operate == OperateE.create
        ? await TOTPKeyList().create(widget.keyIns)
        : await TOTPKeyList().update(widget.keyIns);

    if (res is Failure) {
      copyBack(widget.keyIns, backup);
    }

    return res;
  }
}
