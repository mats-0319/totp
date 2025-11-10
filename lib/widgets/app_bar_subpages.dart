import 'package:flutter/material.dart';

AppBar subpageAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    title: Center(child: Text(title)),
    actions: [
      IconTheme(
        // default leading width is 56
        data: IconThemeData(size: 56, opacity: 0),
        child: Icon(Icons.add),
      ),
    ],
  );
}
