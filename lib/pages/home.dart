import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totp/components/key_instance_active.dart';
import 'package:totp/components/key_instance_silent.dart';
import 'package:totp/model/totp_key.dart';
import 'package:totp/model/totp_key_list.dart';
import 'package:totp/widgets/app_bar.dart';
import 'package:totp/widgets/floating_action_button.dart';

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
      floatingActionButton: floatingActionButton(context),
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
  List<Widget> res = [SizedBox(height: 20)];

  for (var keyIns in list) {
    if (!keyIns.isDeleted && keyIns.key.isNotEmpty) {
      res.add(_KeyInstance(keyIns: keyIns));
    }
  }

  res.add(SizedBox(height: 20));

  return res;
}

class _KeyInstance extends StatefulWidget {
  const _KeyInstance({required this.keyIns});

  final TOTPKey keyIns;

  @override
  State<_KeyInstance> createState() => _KeyInstanceState();
}

class _KeyInstanceState extends State<_KeyInstance> {
  void _onStatusChanged(bool flag) {
    setState(() {
      widget.keyIns.autoActive = flag;
    });
  }

  @override
  Widget build(BuildContext context) {
    late Widget keyItem;
    late double height;

    if (widget.keyIns.autoActive) {
      keyItem = ActiveKeyInstance(
        keyIns: widget.keyIns,
        emitStatus: _onStatusChanged,
      );
      height = 270;
    } else {
      keyItem = SilentKeyInstance(
        keyIns: widget.keyIns,
        emitStatus: _onStatusChanged,
      );
      height = 130;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadiusGeometry.circular(20),
        color: Theme.of(context).colorScheme.onSurface,
      ),
      height: height,
      child: keyItem,
    );
  }
}
