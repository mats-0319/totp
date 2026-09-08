import 'package:flutter/material.dart';
import 'package:totp/components/dialog_modify.dart';
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
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
        borderRadius: BorderRadiusGeometry.circular(20),
      ),
      height: double.infinity,
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
          builder: (context) => ModifyDialog(keyIns: keyIns),
        ),
        child: Text(
          keyIns.name,
          style: blackText(1),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
