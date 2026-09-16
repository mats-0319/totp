import 'package:flutter/material.dart';
import 'package:totp/dart/result.dart';
import 'package:totp/widgets/new_page.dart';
import 'package:totp/widgets/qr_scan.dart';

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
    final theme = Theme.of(context);

    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      style: theme.textTheme.labelLarge,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        labelText: "name",
        labelStyle: theme.textTheme.labelLarge,
      ),
    );
  }
}

class KeyInputReadonly extends StatelessWidget {
  const KeyInputReadonly({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      enabled: false,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.secondary),
        ),
        hintText: text,
        hintStyle: theme.textTheme.displayLarge,
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
    final theme = Theme.of(context);

    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      style: theme.textTheme.bodySmall,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        labelText: "key",
        labelStyle: theme.textTheme.labelLarge,
        suffixIcon: IconButton(
          onPressed: newPage(context, QRScanPage(emitCode: _onScanned)),
          icon: Icon(Icons.crop_free_rounded),
        ),
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
  late bool _value = widget.defaultValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: theme.textTheme.labelLarge),
        Row(
          children: [
            Switch(
              value: _value,
              onChanged: (value) {
                setState(() => _value = value);
                widget.onChanged(value);
              },
            ),
            Text(
              _value ? " ${widget.trueStr}" : " ${widget.falseStr}",
              style: theme.textTheme.labelMedium,
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
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: () async {
        if (_isLoading) {
          return;
        }

        setState(() => _isLoading = true);

        try {
          var res = await widget.func();
          if (!context.mounted) {
            return;
          }

          switch (res) {
            case Success():
              Navigator.of(context).pop();
            case Failure():
              throw res.err;
          }
        } catch (e) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(content: Text(e.toString())),
          );
          setState(() => _isLoading = false);
        }
      },
      child: _textOrLoading(theme),
    );
  }

  Widget _textOrLoading(ThemeData theme) {
    return _isLoading
        ? CircularProgressIndicator(
            color: theme.colorScheme.secondary,
            backgroundColor: theme.colorScheme.surface,
          )
        : Text(widget.text);
  }
}
