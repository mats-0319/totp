import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totp/model/totp_key.dart';
import 'package:totp/model/totp_key_list.dart';
import 'package:totp/widgets/app_bar.dart';
import 'package:totp/widgets/floating_action_button.dart';
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
      floatingActionButton: floatingActionButton(context),
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              ?_initError(dataState.err),
              Expanded(
                child: ListView(children: _displayKeyList(dataState.list)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget? _initError(String err) {
  return err.isNotEmpty ? Text(err) : null;
}

List<Widget> _displayKeyList(List<TOTPKey> list) {
  List<Widget> res = [];

  for (var keyIns in list) {
    if (!keyIns.isDeleted) {
      res.add(_KeyInstance(key: ValueKey(keyIns.key), keyIns: keyIns));
    }
  }

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
    setState(() => isActive = flag);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget keyItem = isActive
        ? ActiveKeyInstance(keyIns: widget.keyIns, onChanged: _onStatusChanged)
        : SilentKeyInstance(keyIns: widget.keyIns, onChanged: _onStatusChanged);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadiusGeometry.circular(20),
        color: theme.colorScheme.onSurface,
      ),
      child: keyItem,
    );
  }
}
