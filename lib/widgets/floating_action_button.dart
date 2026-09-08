import 'package:flutter/material.dart';
import 'package:totp/components/dialog_create.dart';

Widget floatingActionButton(BuildContext context) {
  return FloatingActionButton(
    backgroundColor: Theme.of(context).colorScheme.onSurface,
    onPressed: () =>
        showDialog(context: context, builder: (context) => CreateDialog()),
    child: Icon(Icons.add),
  );
}
