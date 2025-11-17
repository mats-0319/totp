import 'package:flutter/material.dart';
import 'package:totp/theme.dart';
import "package:totp/model/totp_key.dart";
import 'package:totp/model/totp_key_list.dart';
import 'package:totp/widgets/qr_scan.dart';

enum Operate { create, modify, edit }

// include 'create'/'modify'/'edit' dialog in 1
class OperateInstanceDialog extends StatefulWidget {
  OperateInstanceDialog({super.key, required Operate operate, TOTPKey? keyIns})
    : _operate = operate,
      _keyIns = keyIns ?? TOTPKey.empty();

  final Operate _operate;
  final TOTPKey _keyIns;

  @override
  State<OperateInstanceDialog> createState() => _OperateInstanceDialogState();
}

class _OperateInstanceDialogState extends State<OperateInstanceDialog> {
  void _onKeyChanged(String value) {
    setState(() {
      widget._keyIns.key = value;
    });
  }

  void _onNameChanged(String value) {
    setState(() {
      widget._keyIns.name = value;
    });
  }

  void _onAutoActiveChanged(bool value) {
    setState(() {
      widget._keyIns.autoActive = value;
    });
  }

  void _onIsDeletedChanged(bool value) {
    setState(() {
      widget._keyIns.isDeleted = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.only(left: 20, right: 20),
      child: Container(
        padding: EdgeInsets.only(top: 40, bottom: 40, left: 30, right: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _title(),
            SizedBox(height: 30),
            _keyInput(),
            SizedBox(height: 20),
            _NameInput(
              defaultValue: widget._keyIns.name,
              onChanged: _onNameChanged,
            ),
            SizedBox(height: 20),
            _autoActiveSwitch(),
            SizedBox(height: 10),
            _isDeletedSwitch(),
            _confirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    String title = "";

    switch (widget._operate) {
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
    return widget._operate == Operate.modify
        ? _KeyInputReadonly(text: widget._keyIns.key)
        : _KeyInput(defaultValue: widget._keyIns.key, onChanged: _onKeyChanged);
  }

  Widget _autoActiveSwitch() {
    return _SwitchWithDescription(
      defaultValue: widget._keyIns.autoActive,
      onChanged: _onAutoActiveChanged,
      title: "是否在启动时自动激活",
      trueStr: "自动激活",
      falseStr: "不自动激活",
    );
  }

  Widget _isDeletedSwitch() {
    return widget._operate == Operate.edit
        ? _SwitchWithDescription(
            defaultValue: widget._keyIns.isDeleted,
            onChanged: _onIsDeletedChanged,
            title: "是否在主页隐藏该密钥实例",
            trueStr: "隐藏",
            falseStr: "不隐藏",
          )
        : SizedBox();
  }

  Widget _confirmButton() {
    String text = "";
    var method = TOTPKeyList().update();

    switch (widget._operate) {
      case Operate.create:
        text = "创建";
        method = TOTPKeyList().create(widget._keyIns);
      case Operate.modify:
        text = "修改";
      case Operate.edit:
        text = "编辑";
    }

    return ElevatedButton(
      onPressed: () {
        method
            .then((_) {
              Navigator.of(context).pop();
            })
            .catchError((err) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(err)));
            });
      },
      child: Text(text, style: blackText(0)),
    );
  }
}

class _KeyInput extends StatefulWidget {
  const _KeyInput({
    required String defaultValue,
    required Function(String) onChanged,
  }) : _onChanged = onChanged,
       _defaultValue = defaultValue;

  final String _defaultValue;
  final Function(String) _onChanged;

  @override
  State<_KeyInput> createState() => _KeyInputState();
}

class _KeyInputState extends State<_KeyInput> {
  late final _controller = TextEditingController(text: widget._defaultValue);

  void _onScanned(String str) {
    _controller.text = str;
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
      onChanged: widget._onChanged,
      style: blackText(-2),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        labelText: "key",
        suffixIcon: IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => QRScanPage(emitCode: _onScanned),
              ),
            );
          },
          icon: Icon(Icons.crop_free_rounded),
        ),
      ),
    );
  }
}

class _KeyInputReadonly extends StatelessWidget {
  const _KeyInputReadonly({required String text}) : _text = text;

  final String _text;

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
        hintText: _text,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
      ),
    );
  }
}

class _NameInput extends StatefulWidget {
  const _NameInput({
    required String defaultValue,
    required Function(String) onChanged,
  }) : _onChanged = onChanged,
       _defaultValue = defaultValue;

  final String _defaultValue;
  final Function(String) _onChanged;

  @override
  State<_NameInput> createState() => _NameInputState();
}

class _NameInputState extends State<_NameInput> {
  late final _controller = TextEditingController(text: widget._defaultValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget._onChanged,
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
    required bool defaultValue,
    required dynamic Function(bool) onChanged,
    required String title,
    required String trueStr,
    required String falseStr,
  }) : _defaultValue = defaultValue,
       _onChanged = onChanged,
       _title = title,
       _trueStr = trueStr,
       _falseStr = falseStr;

  final bool _defaultValue;
  final Function(bool) _onChanged;
  final String _title;
  final String _trueStr;
  final String _falseStr;

  @override
  State<_SwitchWithDescription> createState() => _SwitchWithDescriptionState();
}

class _SwitchWithDescriptionState extends State<_SwitchWithDescription> {
  late bool _switchValue = widget._defaultValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text(widget._title, style: blackText(-1)),
        ),
        Row(
          children: [
            Switch(
              value: _switchValue,
              onChanged: (value) {
                setState(() {
                  _switchValue = value;
                });
                widget._onChanged(value);
              },
            ),
            Text(" "),
            Text(
              _switchValue ? widget._trueStr : widget._falseStr,
              style: blackText(-2),
            ),
          ],
        ),
      ],
    );
  }
}
