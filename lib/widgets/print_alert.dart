import 'package:flutter/material.dart';

void printAlert(BuildContext context, String str) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(content: Text(str)),
  );
}
