import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'about.dart';
import 'model/totp_key.dart';
import 'model/totp_key_list.dart';
import 'widgets/key_item.dart';
import 'widgets/key_item_empty.dart';
import 'widgets/transition_builder.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var dataState = context.watch<TOTPKeyList>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: SizedBox.shrink(),
        title: Center(child: Text("TOTP")),
        actions: [_ToAboutIcon()],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: ListView(children: displayKeyList(dataState.list))),
          ],
        ),
      ),
    );
  }
}

class _ToAboutIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(size: 28),
      child: IconButton(
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const AboutPage(),
              transitionsBuilder: transition,
            ),
          );
        },
        icon: Icon(Icons.apps),
      ),
    );
  }
}

List<Widget> displayKeyList(List<TOTPKey> list) {
  List<Widget> res = [];
  for (var keyIns in list) {
    if (!keyIns.isDeleted) {
      res.add(KeyItem(keyIns: keyIns));
    }
  }

  res.add(EmptyKeyItem());

  return res;
}
