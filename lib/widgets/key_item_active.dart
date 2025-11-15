import 'dart:async';
import 'package:flutter/material.dart';

import '../dart/totp.dart';
import '../model/totp_key.dart';

class ActiveKeyItem extends StatelessWidget {
  const ActiveKeyItem({
    super.key,
    required this.keyIns,
    required this.emitStatus,
  });

  final TOTPKey keyIns;
  final Function(bool) emitStatus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _NameBar(name: keyIns.name, emitStatus: emitStatus),
          _TimeBasedProgress(keyStr: keyIns.key),
        ],
      ),
    );
  }
}

class _NameBar extends StatelessWidget {
  const _NameBar({required this.name, required this.emitStatus});

  final String name;
  final Function(bool) emitStatus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(name, style: Theme.of(context).textTheme.displayLarge),
        Spacer(),
        ElevatedButton(
          onPressed: () {
            emitStatus(false);
          },
          child: Text("静默", style: Theme.of(context).textTheme.headlineLarge),
        ),
      ],
    );
  }
}

class _TimeBasedProgress extends StatefulWidget {
  const _TimeBasedProgress({required this.keyStr});

  final String keyStr;

  @override
  State<_TimeBasedProgress> createState() => _TimeBasedProgressState();
}

class _TimeBasedProgressState extends State<_TimeBasedProgress> {
  late Timer _timerIns;
  String _totpStr = "";
  double _timeRemain = 0.0;

  @override
  void initState() {
    super.initState();

    _timerIns = Timer.periodic(Duration(milliseconds: 100), (timer) {
      _timeRemain -= 0.1;
      if (_timeRemain <= 0) {
        var (totpStr, timeRemain) = generateTOTP(widget.keyStr);
        _totpStr = totpStr;
        _timeRemain = timeRemain;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timerIns.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 40),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: CircularProgressIndicator(
              value: _timeRemain / 30,
              color: Theme.of(context).colorScheme.secondary,
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
          ),
          Text(_totpStr, style: Theme.of(context).textTheme.displayLarge),
          SizedBox(
            width: double.infinity,
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "剩余：${_timeRemain.toInt()}秒",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
