import 'package:flutter/material.dart';
import 'package:totp/widgets/dialog_create.dart';

import '../model/totp_key.dart';
import '../model/totp_key_list.dart';

class ModifyDialog extends StatefulWidget {
  const ModifyDialog({
    super.key,
    required this.isReadonly,
    required this.keyIns,
  });

  final bool isReadonly;
  final TOTPKey keyIns;

  @override
  State<ModifyDialog> createState() => _ModifyDialogState();
}

class _ModifyDialogState extends State<ModifyDialog> {
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
        padding: EdgeInsets.only(top: 40, bottom: 40, left: 30, right: 30),
        child: Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.isReadonly ? "修改TOTP密钥实例" : "编辑TOTP密钥实例",
                style: Theme.of(context).textTheme.displayMedium,
              ),
              SizedBox(height: 30),
              widget.isReadonly
                  ? _KeyInputReadonly(text: widget.keyIns.key)
                  : KeyInput(
                      defaultValue: widget.keyIns.key,
                      onChanged: _onKeyChanged,
                    ),
              SizedBox(height: 20),
              NameInput(
                defaultValue: widget.keyIns.name,
                onChanged: _onNameChanged,
              ),
              SizedBox(height: 20),
              SwitchWithDescription(
                defaultValue: widget.keyIns.autoActive,
                onChanged: _onAutoActiveChanged,
                title: "是否在启动时自动激活",
                trueStr: "自动激活",
                falseStr: "不自动激活",
              ),
              SizedBox(height: 20),
              !widget.isReadonly
                  ? SwitchWithDescription(
                      defaultValue: widget.keyIns.isDeleted,
                      onChanged: _onIsDeletedChanged,
                      title: "是否在主页隐藏该密钥实例",
                      trueStr: "隐藏",
                      falseStr: "不隐藏",
                    )
                  : SizedBox(),
              _ModifyButton(name: widget.isReadonly ? "修改" : "编辑"),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyInputReadonly extends StatelessWidget {
  const _KeyInputReadonly({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: false,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        hintText: text,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
      ),
    );
  }
}

class _ModifyButton extends StatefulWidget {
  const _ModifyButton({required this.name});

  final String name;

  @override
  State<_ModifyButton> createState() => _ModifyButtonState();
}

class _ModifyButtonState extends State<_ModifyButton> {
  bool _canClick = true;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (!_canClick) {
          return;
        }

        _canClick = false;
        TOTPKeyList()
            .update()
            .then((_) {
              _canClick = true;
              Navigator.of(context).pop();
            })
            .catchError((err) {
              Future.delayed(Duration(milliseconds: 4_000), () {
                _canClick = true;
              });
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(err.toString())));
            });
      },
      child: Text(widget.name, style: Theme.of(context).textTheme.displaySmall),
    );
  }
}
