import 'package:flutter/material.dart';

import '../model/totp_key.dart';
import '../model/totp_key_list.dart';
import 'qr_scan.dart';

class CreateDialog extends StatefulWidget {
  const CreateDialog({super.key});

  @override
  State<CreateDialog> createState() => _CreateDialogState();
}

class _CreateDialogState extends State<CreateDialog> {
  TOTPKey keyIns = TOTPKey.empty();

  void _onKeyChanged(String value) {
    setState(() {
      keyIns.key = value;
    });
  }

  void _onNameChanged(String value) {
    setState(() {
      keyIns.name = value;
    });
  }

  void _onAutoActiveChanged(bool value) {
    setState(() {
      keyIns.autoActive = value;
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
            Text(
              "创建TOTP密钥实例",
              style: Theme.of(context).textTheme.displayMedium,
            ),
            SizedBox(height: 30),
            KeyInput(defaultValue: "", onChanged: _onKeyChanged),
            SizedBox(height: 20),
            NameInput(defaultValue: "", onChanged: _onNameChanged),
            SizedBox(height: 20),
            SwitchWithDescription(
              defaultValue: false,
              onChanged: _onAutoActiveChanged,
              title: "是否在启动时自动激活",
              trueStr: "自动激活",
              falseStr: "不自动激活",
            ),
            SizedBox(height: 20),
            _CreateButton(keyIns: keyIns),
          ],
        ),
      ),
    );
  }
}

class KeyInput extends StatefulWidget {
  const KeyInput({
    super.key,
    required this.defaultValue,
    required this.onChanged,
  });

  final String defaultValue;
  final Function(String) onChanged;

  @override
  State<KeyInput> createState() => _KeyInputState();
}

class _KeyInputState extends State<KeyInput> {
  late final _controller = TextEditingController(text: widget.defaultValue);

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
      onChanged: widget.onChanged,
      style: Theme.of(context).textTheme.headlineMedium,
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

class NameInput extends StatefulWidget {
  const NameInput({
    super.key,
    required this.defaultValue,
    required this.onChanged,
  });

  final String defaultValue;
  final Function(String) onChanged;

  @override
  State<NameInput> createState() => _NameInputState();
}

class _NameInputState extends State<NameInput> {
  late final _controller = TextEditingController(text: widget.defaultValue);

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
      style: Theme.of(context).textTheme.headlineMedium,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        labelText: "密钥名称",
      ),
    );
  }
}

class SwitchWithDescription extends StatefulWidget {
  const SwitchWithDescription({
    super.key,
    required this.defaultValue,
    required this.onChanged,
    required this.title,
    required this.trueStr,
    required this.falseStr,
  });

  final bool defaultValue;
  final Function(bool) onChanged;
  final String title;
  final String trueStr;
  final String falseStr;

  @override
  State<SwitchWithDescription> createState() => _SwitchWithDescriptionState();
}

class _SwitchWithDescriptionState extends State<SwitchWithDescription> {
  late bool needAutoActive = widget.defaultValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        Row(
          children: [
            Switch(
              value: needAutoActive,
              onChanged: (value) {
                setState(() {
                  needAutoActive = value;
                });
                widget.onChanged(value);
              },
            ),
            Text(" "),
            Text(
              needAutoActive ? widget.trueStr : widget.falseStr,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ],
    );
  }
}

class _CreateButton extends StatefulWidget {
  const _CreateButton({required this.keyIns});

  final TOTPKey keyIns;

  @override
  State<_CreateButton> createState() => _CreateButtonState();
}

class _CreateButtonState extends State<_CreateButton> {
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
            .create(widget.keyIns)
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
              ).showSnackBar(SnackBar(content: Text(err)));
            });
      },
      child: Text("创建", style: Theme.of(context).textTheme.displaySmall),
    );
  }
}
