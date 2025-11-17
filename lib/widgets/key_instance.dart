import 'package:flutter/material.dart';

import 'package:totp/model/totp_key.dart';
import 'package:totp/widgets/key_instance_empty.dart';
import 'package:totp/widgets/key_instance_active.dart';
import 'package:totp/widgets/key_instance_silent.dart';

class KeyInstance extends StatefulWidget {
  const KeyInstance({super.key, required TOTPKey keyIns}) : _keyIns = keyIns;

  final TOTPKey _keyIns;

  @override
  State<KeyInstance> createState() => _KeyInstanceState();
}

class _KeyInstanceState extends State<KeyInstance> {
  late bool _isActive = widget._keyIns.autoActive;

  void _onStatusChanged(bool flag) {
    setState(() {
      _isActive = flag;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget keyItem = EmptyKeyInstance();
    double height = 200;

    if (widget._keyIns.key.isNotEmpty) {
      if (_isActive) {
        keyItem = ActiveKeyInstance(
          keyIns: widget._keyIns,
          emitStatus: _onStatusChanged,
        );
        height = 300;
      } else {
        keyItem = SilentKeyInstance(
          keyIns: widget._keyIns,
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
