import 'package:flutter/material.dart';

import '../model/totp_key.dart';
import '../model/totp_key_list.dart';
import '../components/slide_horizontal.dart';
import 'dialog_modify.dart';

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
      onTap: () async {
        await TOTPKeyList().delete(keyStr);
      },
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
        child: Text("删除", style: TextStyle(color: Colors.white)),
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
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => ModifyDialog(isReadonly: true, keyIns: keyIns),
          );
        },
        child: Text(
          keyIns.name,
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
    );
  }
}

class _ActiveButton extends StatelessWidget {
  const _ActiveButton({required this.emitStatus});

  final Function(bool) emitStatus;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        emitStatus(true);
      },
      child: Text("激活", style: Theme.of(context).textTheme.headlineLarge),
    );
  }
}
