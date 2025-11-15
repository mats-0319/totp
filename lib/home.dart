import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totp/widgets/app_bar.dart';

import 'model/totp_key.dart';
import 'model/totp_key_list.dart';
import 'widgets/key_item.dart';

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
      appBar: homepageAppBar(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: ListView(children: _displayKeyList(dataState.list))),
          ],
        ),
      ),
    );
  }
}

List<Widget> _displayKeyList(List<TOTPKey> list) {
  List<Widget> res = [];
  for (var keyIns in list) {
    if (!keyIns.isDeleted && keyIns.key.isNotEmpty) {
      res.add(KeyItem(keyIns: keyIns));
    }
  }

  // make sure there is a 'empty key item' at last
  res.add(KeyItem(keyIns: TOTPKey.empty()));

  return res;
}
