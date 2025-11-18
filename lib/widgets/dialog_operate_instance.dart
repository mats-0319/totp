import 'package:flutter/material.dart';
import 'package:totp/theme.dart';
import "package:totp/model/totp_key.dart";
import 'package:totp/model/totp_key_list.dart';
import 'package:totp/widgets/qr_scan.dart';

enum Operate { create, modify, edit }

// include 'create'/'modify'/'edit' dialog in 1
class OperateInstanceDialog extends StatefulWidget {
  OperateInstanceDialog({super.key, required this.operate, TOTPKey? keyIns})
    : keyIns = keyIns ?? TOTPKey.empty();

  final Operate operate;
  final TOTPKey keyIns;

  @override
  State<OperateInstanceDialog> createState() => _OperateInstanceDialogState();
}

class _OperateInstanceDialogState extends State<OperateInstanceDialog> {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _title(),
            SizedBox(height: 30),
            _keyInput(),
            SizedBox(height: 20),
            _NameInput(
              initValue: widget.keyIns.name,
              onChanged: _onNameChanged,
            ),
            SizedBox(height: 20),
            _autoActiveSwitch(),
            SizedBox(height: 10),
            _isDeletedSwitch(),
            _ConfirmButton(operate: widget.operate, keyIns: widget.keyIns),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    String title = "";

    switch (widget.operate) {
      case Operate.create:
        title = "创建";
      case Operate.modify:
        title = "修改";
      case Operate.edit:
        title = "编辑";
    }

    return Text("${title}TOTP密钥实例", style: blackText(1));
  }

  Widget _keyInput() {
    return widget.operate == Operate.modify
        ? _KeyInputReadonly(text: widget.keyIns.key)
        : _KeyInput(initValue: widget.keyIns.key, onChanged: _onKeyChanged);
  }

  Widget _autoActiveSwitch() {
    return _SwitchWithDescription(
      initValue: widget.keyIns.autoActive,
      onChanged: _onAutoActiveChanged,
      title: "是否在启动时自动激活",
      trueStr: "自动激活",
      falseStr: "不自动激活",
    );
  }

  Widget _isDeletedSwitch() {
    return widget.operate == Operate.edit
        ? _SwitchWithDescription(
            initValue: widget.keyIns.isDeleted,
            onChanged: _onIsDeletedChanged,
            title: "是否在主页隐藏该密钥实例",
            trueStr: "隐藏",
            falseStr: "不隐藏",
          )
        : SizedBox();
  }
}

class _KeyInput extends StatefulWidget {
  const _KeyInput({required this.initValue, required this.onChanged});

  final String initValue;
  final Function(String) onChanged;

  @override
  State<_KeyInput> createState() => _KeyInputState();
}

class _KeyInputState extends State<_KeyInput> {
  late final _controller = TextEditingController(text: widget.initValue);

  void _onScanned(String str) {
    _controller.text = str;
    // 设置controller.text不会触发onChanged，所以要在这里单独调用一次
    widget.onChanged(str);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      style: blackText(-2),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        labelText: "key",
        suffixIcon: IconButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => QRScanPage(emitCode: _onScanned),
            ),
          ),
          icon: Icon(Icons.crop_free_rounded),
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

class _NameInput extends StatefulWidget {
  const _NameInput({required this.initValue, required this.onChanged});

  final String initValue;
  final Function(String) onChanged;

  @override
  State<_NameInput> createState() => _NameInputState();
}

class _NameInputState extends State<_NameInput> {
  late final _controller = TextEditingController(text: widget.initValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      style: blackText(-2),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        labelText: "密钥名称",
      ),
    );
  }
}

class _SwitchWithDescription extends StatefulWidget {
  const _SwitchWithDescription({
    required this.initValue,
    required this.onChanged,
    required this.title,
    required this.trueStr,
    required this.falseStr,
  });

  final bool initValue;
  final Function(bool) onChanged;
  final String title;
  final String trueStr;
  final String falseStr;

  @override
  State<_SwitchWithDescription> createState() => _SwitchWithDescriptionState();
}

class _SwitchWithDescriptionState extends State<_SwitchWithDescription> {
  late bool _switchValue = widget.initValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text(widget.title, style: blackText(-1)),
        ),
        Row(
          children: [
            Switch(
              value: _switchValue,
              onChanged: (value) {
                setState(() {
                  _switchValue = value;
                });
                widget.onChanged(value);
              },
            ),
            Text(" "),
            Text(
              _switchValue ? widget.trueStr : widget.falseStr,
              style: blackText(-2),
            ),
          ],
        ),
      ],
    );
  }
}

class _ConfirmButton extends StatefulWidget {
  const _ConfirmButton({required Operate operate, required TOTPKey keyIns})
    : _operate = operate,
      _keyIns = keyIns;

  final Operate _operate;
  final TOTPKey _keyIns;

  @override
  State<_ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<_ConfirmButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    String text = "";
    Function method = TOTPKeyList().createOrUpdate(null);

    switch (widget._operate) {
      case Operate.create:
        text = "创建";
        method = TOTPKeyList().createOrUpdate(widget._keyIns);
      case Operate.modify:
        text = "修改";
      case Operate.edit:
        text = "编辑";
    }

    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              method()
                  .then((_) {
                    Navigator.of(context).pop();
                  })
                  .catchError((err) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(content: Text(err)),
                    );
                  })
                  .whenComplete(() {
                    setState(() {
                      _isLoading = false;
                    });
                  });
            },
      child: _isLoading
          ? CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
              backgroundColor: Theme.of(context).colorScheme.surface,
            )
          : Text(text, style: blackText(0)),
    );
  }
}
