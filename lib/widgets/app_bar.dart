import 'package:flutter/material.dart';
import 'package:totp/pages/about.dart';
import 'package:totp/widgets/new_page.dart';

AppBar homepageAppBar(BuildContext context) {
  final theme = Theme.of(context);

  return AppBar(
    leading: SizedBox.shrink(),
    title: Center(child: Text("TOTP", style: theme.textTheme.titleLarge)),
    actions: [
      IconButton(
        onPressed: newPage(context, const AboutPage()),
        icon: const Icon(Icons.apps),
      ),
    ],
  );
}

AppBar subpageAppBar(BuildContext context, String title) {
  final theme = Theme.of(context);

  return AppBar(
    leading: BackButton(color: theme.colorScheme.primary),
    title: Center(child: Text(title, style: theme.textTheme.titleLarge)),
    actions: [SizedBox(width: 56)], // default leading width is 56
  );
}
