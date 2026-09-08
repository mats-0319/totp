import 'package:flutter/material.dart';
import "package:totp/components/dialog_components.dart";
import 'package:totp/model/totp_key.dart';
import 'package:totp/model/totp_key_list.dart';
import 'package:totp/theme.dart';

class EditDialog extends StatefulWidget {
  const EditDialog({super.key, required this.keyIns});

  final TOTPKey keyIns;

  @override
  State<StatefulWidget> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  void _onKeyChanged(String value) {
    setState(() {
      widget.keyIns.key = value;
    });
  }

  void _onNameChanged(String value) {
    setState(() {
      widget.keyIns.name = value;
    });
  }

  void _onAutoActiveChanged(bool value) {
    setState(() {
      widget.keyIns.autoActive = value;
    });
  }

  void _onIsDeletedChanged(bool value) {
    setState(() {
      widget.keyIns.isDeleted = value;
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
            Text("编辑TOTP密钥实例", style: blackText(1)),
            SizedBox(height: 30),
            NameInput(
              defaultValue: widget.keyIns.name,
              onChanged: _onNameChanged,
            ),
            SizedBox(height: 20),
            KeyInput(defaultValue: widget.keyIns.key, onChanged: _onKeyChanged),
            SizedBox(height: 20),
            SwitchWithDescription(
              defaultValue: widget.keyIns.autoActive,
              onChanged: _onAutoActiveChanged,
              title: "是否在启动时自动激活",
              trueStr: "自动激活",
              falseStr: "不自动激活",
            ),
            SizedBox(height: 10),
            SwitchWithDescription(
              defaultValue: widget.keyIns.isDeleted,
              onChanged: _onIsDeletedChanged,
              title: "是否在主页隐藏该密钥",
              trueStr: "隐藏",
              falseStr: "不隐藏",
            ),
            SizedBox(height: 20),
            ConfirmButton(
              text: "编辑",
              func: () => TOTPKeyList().update(widget.keyIns.key),
            ),
          ],
        ),
      ),
    );
  }
}
