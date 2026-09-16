import 'package:flutter/material.dart';
import 'package:totp/model/totp_key.dart';
import 'package:totp/widgets/dialog_instance.dart';

Widget floatingActionButton(BuildContext context) {
  return FloatingActionButton(
    onPressed: () => showDialog(
      context: context,
      builder: (context) =>
          OperateDialog(operate: OperateE.create, keyIns: TOTPKey.empty()),
    ),
    child: Icon(Icons.add),
  );
}
