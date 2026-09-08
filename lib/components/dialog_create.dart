import 'package:flutter/material.dart';
import "package:totp/components/dialog_components.dart";
import 'package:totp/model/totp_key.dart';
import 'package:totp/model/totp_key_list.dart';
import 'package:totp/theme.dart';

class CreateDialog extends StatefulWidget {
  CreateDialog({super.key});

  final TOTPKey keyIns = TOTPKey.empty();

  @override
  State<StatefulWidget> createState() => _CreateDialogState();
}

class _CreateDialogState extends State<CreateDialog> {
  void _onNameChanged(String value) {
    setState(() {
      widget.keyIns.name = value;
    });
  }

  void _onKeyChanged(String value) {
    setState(() {
      widget.keyIns.key = value;
    });
  }

  void _onAutoActiveChanged(bool value) {
    setState(() {
      widget.keyIns.autoActive = value;
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
            Text("创建TOTP密钥实例", style: blackText(1)),
            SizedBox(height: 30),
            NameInput(onChanged: _onNameChanged),
            SizedBox(height: 20),
            KeyInput(onChanged: _onKeyChanged),
            SizedBox(height: 20),
            SwitchWithDescription(
              defaultValue: widget.keyIns.autoActive,
              onChanged: _onAutoActiveChanged,
              title: "是否在启动时自动激活",
              trueStr: "自动激活",
              falseStr: "不自动激活",
            ),
            SizedBox(height: 20),
            ConfirmButton(
              text: "创建",
              func: () => TOTPKeyList().create(widget.keyIns),
            ),
          ],
        ),
      ),
    );
  }
}
