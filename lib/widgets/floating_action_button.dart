import 'package:flutter/material.dart';
import 'package:totp/components/dialog_instance.dart';
import 'package:totp/model/totp_key.dart';

Widget floatingActionButton(BuildContext context) {
  return FloatingActionButton(
    backgroundColor: Theme.of(context).colorScheme.onSurface,
    onPressed: () => showDialog(
      context: context,
      builder: (context) =>
          OperateDialog(operate: OperateE.create, keyIns: TOTPKey.empty()),
    ),
    child: Icon(Icons.add),
  );
}
