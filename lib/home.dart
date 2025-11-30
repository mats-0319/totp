import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:totp/model/totp_key.dart';
import 'package:totp/model/totp_key_list.dart';
import 'package:totp/widgets/app_bar.dart';
import 'package:totp/widgets/key_instance_empty.dart';
import 'package:totp/widgets/key_instance_active.dart';
import 'package:totp/widgets/key_instance_silent.dart';

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
            Expanded(
              child: ListView(children: _displayKeyList(dataState.list)),
            ),
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
      res.add(_KeyInstance(keyIns: keyIns));
    }
  }

  // make sure there is a 'empty key item' at last
  res.add(_KeyInstance(keyIns: TOTPKey.empty()));

  return res;
}

class _KeyInstance extends StatefulWidget {
  const _KeyInstance({required this.keyIns});

  final TOTPKey keyIns;

  @override
  State<_KeyInstance> createState() => _KeyInstanceState();
}

class _KeyInstanceState extends State<_KeyInstance> {
  late bool _isActive = widget.keyIns.autoActive;

  void _onStatusChanged(bool flag) {
    setState(() {
      _isActive = flag;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget keyItem = EmptyKeyInstance();
    double height = 200;

    if (widget.keyIns.key.isNotEmpty) {
      if (_isActive) {
        keyItem = ActiveKeyInstance(
          keyIns: widget.keyIns,
          emitStatus: _onStatusChanged,
        );
        height = 300;
      } else {
        keyItem = SilentKeyInstance(
          keyIns: widget.keyIns,
          emitStatus: _onStatusChanged,
        );
      }
    }

    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadiusGeometry.circular(20),
        color: Theme.of(context).colorScheme.onSurface,
      ),
      height: height,
      child: keyItem,
    );
  }
}
