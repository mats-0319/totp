import 'package:flutter/material.dart';
import 'package:totp/components/dialog_instance.dart';
import 'package:totp/model/totp_key.dart';
import 'package:totp/theme.dart';

class SilentKeyInstance extends StatelessWidget {
  const SilentKeyInstance({
    super.key,
    required this.keyIns,
    required this.emitStatus,
  });

  final TOTPKey keyIns;
  final Function(bool) emitStatus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Row(
        children: [
          _ModifyButton(keyIns: keyIns),
          Spacer(),
          ElevatedButton(
            onPressed: () => emitStatus(true),
            child: Text("激活", style: blackText(-1)),
          ),
        ],
      ),
    );
  }
}

class _ModifyButton extends StatelessWidget {
  const _ModifyButton({required this.keyIns});

  final TOTPKey keyIns;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 60,
      child: ElevatedButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) =>
              OperateDialog(operate: OperateE.modify, keyIns: keyIns),
        ),
        child: Text(
          keyIns.name,
          style: blackText(0),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
