import 'package:flutter/material.dart';
import 'package:totp/pages/about.dart';
import 'package:totp/widgets/new_page.dart';

AppBar homepageAppBar(BuildContext context) {
  final theme = Theme.of(context);

  return AppBar(
    leading: SizedBox.shrink(),
    title: Center(child: Text("TOTP", style: theme.textTheme.headlineLarge)),
    actions: [_ToAboutIcon()],
  );
}

AppBar subpageAppBar(BuildContext context, String title) {
  final theme = Theme.of(context);

  return AppBar(
    leading: BackButton(color: theme.colorScheme.primary),
    title: Center(child: Text(title, style: theme.textTheme.headlineLarge)),
    actions: [SizedBox(width: 56)], // default leading width is 56
  );
}

class _ToAboutIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(size: 28),
      child: IconButton(
        onPressed: newPage(context, const AboutPage()),
        icon: Icon(Icons.apps),
      ),
    );
  }
}
