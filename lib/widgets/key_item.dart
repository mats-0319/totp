import 'package:flutter/material.dart';
import 'package:totp/widgets/key_item_empty.dart';

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
    Widget keyItem = EmptyKeyItem();
    double height = 200;

    if (widget.keyIns.key.isNotEmpty) {
      if (isActive) {
        keyItem = ActiveKeyItem(
          keyIns: widget.keyIns,
          emitStatus: _onStatusChanged,
        );
        height = 300;
      } else {
        keyItem = SilentKeyItem(
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
