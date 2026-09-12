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
            ?_dataError(),
            Expanded(
              child: ListView(children: _displayKeyList(dataState.list)),
            ),
          ],
        ),
      ),
    );
  }
}

Widget? _dataError() {
  if (TOTPKeyList().err.isNotEmpty) {
    return Text(TOTPKeyList().err);
  }

  return null;
}

List<Widget> _displayKeyList(List<TOTPKey> list) {
  List<Widget> res = [SizedBox(height: 20)];

  for (var keyIns in list) {
    if (!keyIns.isDeleted) {
      res.add(_KeyInstance(key: ValueKey(keyIns.key), keyIns: keyIns));
    }
  }

  res.add(SizedBox(height: 20));

  return res;
}

class _KeyInstance extends StatefulWidget {
  const _KeyInstance({super.key, required this.keyIns});

  final TOTPKey keyIns;

  @override
  State<_KeyInstance> createState() => _KeyInstanceState();
}

class _KeyInstanceState extends State<_KeyInstance> {
  late bool isActive = widget.keyIns.autoActive;

  void _onStatusChanged(bool flag) {
    setState(() {
      isActive = flag;
    });
  }

  @override
  Widget build(BuildContext context) {
    late Widget keyItem;

    if (isActive) {
      keyItem = ActiveKeyInstance(
        keyIns: widget.keyIns,
        emitStatus: _onStatusChanged,
      );
    } else {
      keyItem = SilentKeyInstance(
        keyIns: widget.keyIns,
        emitStatus: _onStatusChanged,
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadiusGeometry.circular(20),
        color: Theme.of(context).colorScheme.onSurface,
      ),
      child: keyItem,
    );
  }
}
