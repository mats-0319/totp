import 'package:flutter/material.dart';

import '../model/totp_key.dart';
import '../model/totp_key_list.dart';

class EmptyKeyItem extends StatelessWidget {
  const EmptyKeyItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: BoxBorder.all(width: 2, color: Colors.grey),
        borderRadius: BorderRadiusGeometry.circular(20),
      ),
      height: 200,
      child: Padding(
        padding: EdgeInsets.all(40),
        child: IconTheme(
          data: IconThemeData(size: 60, opacity: 0.3),
          child: IconButton(
            onPressed: () async {
              await _openCreateDialog(context);
            },
            icon: Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  Future<void> _openCreateDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.only(left: 20, right: 20),
          child: _CreateDialog(),
        );
      },
    );
  }
}

class _CreateDialog extends StatefulWidget {
  @override
  State<_CreateDialog> createState() => _CreateDialogState();
}

class _CreateDialogState extends State<_CreateDialog> {
  String key = "";
  String name = "";
  bool needAutoActive = false;

  void _onKeyChanged(String value) {
    setState(() {
      key = value;
    });
  }

  void _onNameChanged(String value) {
    setState(() {
      name = value;
    });
  }

  void _onAutoActiveChanged(bool value) {
    setState(() {
      needAutoActive = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(padding: EdgeInsets.all(20), child: Text("创建TOTP密钥实例")),
          Padding(
            padding: EdgeInsets.all(12),
            child: _Input(text: "key", onChanged: _onKeyChanged),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: _Input(text: "密钥名称", onChanged: _onNameChanged),
          ),
          Padding(
            padding: EdgeInsets.only(left: 12, right: 12),
            child: _AutoActiveSwitch(emitStatus: _onAutoActiveChanged),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: _CreateButton(
              keyStr: key,
              name: name,
              needAutoActive: needAutoActive,
            ),
          ),
        ],
      ),
    );
  }
}

class _Input extends StatefulWidget {
  const _Input({required this.text, required this.onChanged});

  final String text;
  final Function(String) onChanged;

  @override
  State<_Input> createState() => _InputState();
}

class _InputState extends State<_Input> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        labelText: widget.text,
      ),
    );
  }
}

class _AutoActiveSwitch extends StatefulWidget {
  const _AutoActiveSwitch({required this.emitStatus});

  final Function(bool) emitStatus;

  @override
  State<_AutoActiveSwitch> createState() => _AutoActiveSwitchState();
}

class _AutoActiveSwitchState extends State<_AutoActiveSwitch> {
  bool needAutoActive = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(top: 10),
          child: Text("是否在启动时自动激活"),
        ),
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

class _CreateButton extends StatelessWidget {
  const _CreateButton({
    required this.keyStr,
    required this.name,
    required this.needAutoActive,
  });

  final String keyStr;
  final String name;
  final bool needAutoActive;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await TOTPKeyList().create(TOTPKey(keyStr, name, needAutoActive));
        Navigator.of(context).pop();
      },
      child: Text("创建"),
    );
  }
}
