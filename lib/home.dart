import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totp/model/totp_key.dart';
import 'package:totp/widgets/home_to_about_icon.dart';
import 'package:totp/widgets/key_item.dart';
import 'package:totp/widgets/key_item_empty.dart';

import 'model/totp_key_list.dart';

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
        actions: [HomeToAboutIcon()],
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
