import 'package:flutter/material.dart';
import 'package:totp/model/totp_key.dart';
import 'package:totp/widgets/dialog_instance.dart';

class SilentKeyInstance extends StatelessWidget {
  const SilentKeyInstance({
    super.key,
    required this.keyIns,
    required this.onChanged,
  });

  final TOTPKey keyIns;
  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ModifyButton(keyIns: keyIns),
        Spacer(),
        ElevatedButton(onPressed: () => onChanged(true), child: Text("激活")),
      ],
    );
  }
}

class _ModifyButton extends StatelessWidget {
  const _ModifyButton({required this.keyIns});

  final TOTPKey keyIns;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(fixedSize: Size(200, 50)),
      onPressed: () => showDialog(
        context: context,
        builder: (context) =>
            OperateDialog(operate: OperateE.modify, keyIns: keyIns),
      ),
      child: Text(
        keyIns.name,
        style: theme.textTheme.headlineMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
