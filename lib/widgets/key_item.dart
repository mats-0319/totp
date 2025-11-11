import 'package:flutter/material.dart';

import 'key_item_active.dart';
import 'key_item_silent.dart';
import '../model/totp_key.dart';

class KeyItem extends StatefulWidget {
  const KeyItem({super.key, required this.keyIns});

  final TOTPKey keyIns;

  @override
  State<KeyItem> createState() => _KeyItemState();
}

class _KeyItemState extends State<KeyItem> {
  late bool isActive = widget.keyIns.autoActive;

  void _onStatusChanged(bool flag) {
    setState(() {
      isActive = flag;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isActive
        ? ActiveKeyItem(keyIns: widget.keyIns, emitStatus: _onStatusChanged)
        : SilentKeyItem(keyIns: widget.keyIns, emitStatus: _onStatusChanged);
  }
}
