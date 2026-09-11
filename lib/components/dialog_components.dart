import 'package:flutter/material.dart';
import 'package:totp/components/qr_scan.dart';
import 'package:totp/dart/result.dart';
import 'package:totp/theme.dart';
import 'package:totp/widgets/print_alert.dart';

class KeyInputReadonly extends StatelessWidget {
  const KeyInputReadonly({super.key, required this.text});

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

class KeyInput extends StatefulWidget {
  const KeyInput({super.key, this.defaultValue = "", required this.onChanged});

  final String defaultValue;
  final Function(String) onChanged;

  @override
  State<KeyInput> createState() => _KeyInputState();
}

class _KeyInputState extends State<KeyInput> {
  late final _controller = TextEditingController(text: widget.defaultValue);

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

class NameInput extends StatefulWidget {
  const NameInput({super.key, this.defaultValue = "", required this.onChanged});

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
  late bool _switchValue = widget.defaultValue;

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

class ConfirmButton extends StatefulWidget {
  const ConfirmButton({super.key, required this.text, required this.func});

  final String text;
  final Future<Result<void>> Function() func;

  @override
  State<ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<ConfirmButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });

              var res = await widget.func();
              if (!context.mounted) {
                // 弹窗已经被关闭，继续 setState 会抛 "setState() called after dispose"
                return;
              }

              switch (res) {
                case Success():
                  Navigator.of(context).pop();
                case Failure():
                  printAlert(context, res.err);
              }
              setState(() {
                _isLoading = false;
              });
            },
      child: _isLoading
          ? CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
              backgroundColor: Theme.of(context).colorScheme.surface,
            )
          : Text(widget.text, style: blackText(-1)),
    );
  }
}
