import 'package:flutter/material.dart';

import '../model/totp_key.dart';
import '../model/totp_key_list.dart';
import '../components/slide_horizontal.dart';

class SilentKeyItem extends StatelessWidget {
  const SilentKeyItem({
    super.key,
    required this.keyIns,
    required this.emitStatus,
  });

  final TOTPKey keyIns;
  final Function(bool) emitStatus;

  @override
  Widget build(BuildContext context) {
    return Slide(
      actions: [_DeleteButton(keyStr: keyIns.key)],
      actionsWidth: 100,
      keyStr: Key(""),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: BoxBorder.all(width: 2, color: Colors.grey),
          borderRadius: BorderRadiusGeometry.circular(20),
        ),
        height: 200,
        child: Row(
          children: [
            _KeyDetails(keyIns: keyIns),
            Spacer(),
            _ActiveButton(emitStatus: emitStatus),
          ],
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.keyStr});

  final String keyStr;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        alignment: Alignment.center,
        width: 120,
        decoration: BoxDecoration(
          color: Colors.red[300],
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: TextButton(
          // style: ButtonStyle(),
          onPressed: () async {
            await TOTPKeyList().delete(keyStr);
          },
          child: Text(
            "删除",
            textScaler: TextScaler.linear(1.6),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _KeyDetails extends StatelessWidget {
  const _KeyDetails({required this.keyIns});

  final TOTPKey keyIns;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: 200,
      height: 90,
      child: ElevatedButton(
        onPressed: () async {
          await _openModifyDialog(context);
        },
        child: Text(keyIns.name, textScaler: TextScaler.linear(1.8)),
      ),
    );
  }

  Future<void> _openModifyDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.only(left: 20, right: 20),
          child: _ModifyDialogForm(keyIns: keyIns),
        );
      },
    );
  }
}

class _ActiveButton extends StatelessWidget {
  const _ActiveButton({required this.emitStatus});

  final Function(bool) emitStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          emitStatus(true);
        },
        child: Text("激活", textScaler: TextScaler.linear(1.6)),
      ),
    );
  }
}

class _ModifyDialogForm extends StatefulWidget {
  const _ModifyDialogForm({required this.keyIns});

  final TOTPKey keyIns;

  @override
  State<_ModifyDialogForm> createState() => _ModifyDialogFormState();
}

class _ModifyDialogFormState extends State<_ModifyDialogForm> {
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

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(padding: EdgeInsets.all(20), child: Text("修改TOTP密钥实例")),
          Padding(
            padding: EdgeInsets.all(12),
            child: _KeyInput(text: widget.keyIns.key),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: _NameInput(
              text: widget.keyIns.name,
              onChanged: _onNameChanged,
            ),
          ),
          Container(
            height: 80,
            padding: EdgeInsets.only(left: 12, right: 12),
            child: _AutoActiveSwitch(
              defaultValue: widget.keyIns.autoActive,
              emitStatus: _onAutoActiveChanged,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: _ModifyButton(keyIns: widget.keyIns),
          ),
        ],
      ),
    );
  }
}

class _KeyInput extends StatelessWidget {
  const _KeyInput({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: false,
      decoration: InputDecoration(border: OutlineInputBorder(), hintText: text),
    );
  }
}

class _NameInput extends StatelessWidget {
  const _NameInput({required this.text, required this.onChanged});

  final String text;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "密钥名称",
        hintText: text,
      ),
    );
  }
}

class _AutoActiveSwitch extends StatefulWidget {
  const _AutoActiveSwitch({
    required this.defaultValue,
    required this.emitStatus,
  });

  final bool defaultValue;
  final Function(bool) emitStatus;

  @override
  State<_AutoActiveSwitch> createState() => _AutoActiveSwitchState();
}

class _AutoActiveSwitchState extends State<_AutoActiveSwitch> {
  late bool needAutoActive = widget.defaultValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(alignment: Alignment.centerLeft, child: Text("是否在启动时自动激活")),
        Row(
          children: [
            Switch(
              value: needAutoActive,
              onChanged: (value) {
                setState(() {
                  needAutoActive = value;
                });
                widget.emitStatus(value);
              },
            ),
            Text(needAutoActive ? "自动激活" : "不自动激活"),
          ],
        ),
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
      onPressed: () async {
        await TOTPKeyList().update(keyIns);
        Navigator.of(context).pop();
      },
      child: Text("修改"),
    );
  }
}
