import 'package:flutter/material.dart';

import 'package:totp/theme.dart';
import 'package:totp/components/slide_horizontal.dart';
import 'package:totp/model/totp_key.dart';
import 'package:totp/model/totp_key_list.dart';
import 'package:totp/widgets/dialog_operate_instance.dart';

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
    return Slide(
      actions: [_DeleteButton(keyStr: keyIns.key)],
      actionsWidth: 100,
      keyStr: Key(keyIns.key),
      child: Container(
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
            _activeButton(),
          ],
        ),
      ),
    );
  }

  Widget _activeButton() {
    return ElevatedButton(
      onPressed: () => emitStatus(true),
      child: Text("激活", style: blackText(-1)),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.keyStr});

  final String keyStr;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => TOTPKeyList().delete(keyStr),
      child: Container(
        alignment: Alignment.center,
        width: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Text(
          "删除",
          style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
        ),
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
              OperateInstanceDialog(operate: Operate.modify, keyIns: keyIns),
        ),
        child: Text(keyIns.name, style: blackText(1)),
      ),
    );
  }
}
