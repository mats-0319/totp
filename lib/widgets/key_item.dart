import 'package:flutter/material.dart';
import 'package:totp/widgets/key_item_silent.dart';
import '../model/totp_key.dart';
import 'key_item_active.dart';

class KeyItem extends StatefulWidget {
  KeyItem({super.key, required this.keyIns});

  final TOTPKey keyIns;
  late bool isActive = keyIns.autoActive;

  @override
  State<KeyItem> createState() => _KeyItemState();
}

class _KeyItemState extends State<KeyItem> {
  void _onStatusChanged(bool flag) {
    setState(() {
      widget.isActive = flag;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.isActive
        ? ActiveKeyItem(keyIns: widget.keyIns, emitStatus: _onStatusChanged)
        : SilentKeyItem(keyIns: widget.keyIns, emitStatus: _onStatusChanged);
  }
}
