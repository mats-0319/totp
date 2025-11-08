import 'package:flutter/material.dart';
import 'package:totp/model/totp_key_list.dart';
import 'package:totp/model/totp_key.dart';

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
      child: Container(
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
          child: _CreateDialogForm(),
        );
      },
    );
  }
}

class _CreateDialogForm extends StatefulWidget {
  @override
  State<_CreateDialogForm> createState() => _CreateDialogFormState();
}

class _CreateDialogFormState extends State<_CreateDialogForm> {
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
            child: _KeyInput(onChanged: _onKeyChanged),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: _NameInput(onChanged: _onNameChanged),
          ),
          Container(
            height: 80,
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

class _KeyInput extends StatelessWidget {
  const _KeyInput({required this.onChanged});

  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "key",
        hintText: "key",
      ),
    );
  }
}

class _NameInput extends StatelessWidget {
  const _NameInput({required this.onChanged});

  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "密钥名称",
        hintText: "密钥名称",
      ),
    );
  }
}

class _AutoActiveSwitch extends StatefulWidget {
  const _AutoActiveSwitch({required this.emitStatus});

  final Function(bool) emitStatus;

  @override
  State<_AutoActiveSwitch> createState() =>
      _AutoActiveSwitchState(emitStatus: emitStatus);
}

class _AutoActiveSwitchState extends State<_AutoActiveSwitch> {
  _AutoActiveSwitchState({required this.emitStatus});

  final Function(bool) emitStatus;
  bool needAutoActive = false;

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
                emitStatus(value);
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
