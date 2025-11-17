import 'dart:async';
import 'package:flutter/material.dart';

import 'package:totp/theme.dart';
import 'package:totp/dart/totp.dart';
import 'package:totp/model/totp_key.dart';

class ActiveKeyInstance extends StatelessWidget {
  const ActiveKeyInstance({
    super.key,
    required TOTPKey keyIns,
    required Function(bool) emitStatus,
  }) : _emitStatus = emitStatus,
       _keyIns = keyIns;

  final TOTPKey _keyIns;
  final Function(bool) _emitStatus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _nameBar(),
          _TimeBasedProgress(keyStr: _keyIns.key),
        ],
      ),
    );
  }
  
  Widget _nameBar() {
    return Row(
      children: [
        Text(_keyIns.name, style: blackText(2)),
        Spacer(),
        ElevatedButton(
          onPressed: () {
            _emitStatus(false);
          },
          child: Text("静默", style: blackText(-1)),
        ),
      ],
    );
  }
}

class _TimeBasedProgress extends StatefulWidget {
  const _TimeBasedProgress({required String keyStr}) : _keyStr = keyStr;

  final String _keyStr;

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
        var (totpStr, timeRemain) = generateTOTP(widget._keyStr);
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
          Text(_totpStr, style: blackText(2)),
          SizedBox(
            width: double.infinity,
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("剩余：${_timeRemain.toInt()}秒", style: blackText(-2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
