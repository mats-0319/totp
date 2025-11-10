import 'dart:async';

import 'package:flutter/material.dart';
import 'package:totp/dart/totp.dart';

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
    return Container(
      decoration: BoxDecoration(
        border: BoxBorder.all(width: 2, color: Colors.grey),
        borderRadius: BorderRadiusGeometry.circular(20),
      ),
      height: 300,
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Text(keyIns.name, textScaler: TextScaler.linear(2.2)),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    emitStatus(false);
                  },
                  child: Text("静默", textScaler: TextScaler.linear(1.6)),
                ),
              ],
            ),
            SizedBox(height: 40,),
            _TimeBasedProgress(keyStr: keyIns.key),
          ],
        ),
      ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(width: 80),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                value: _timeRemain / 30,
                backgroundColor: Colors.grey[200],
              ),
            ),
            Text(_totpStr, textScaler: TextScaler.linear(2)),
          ],
        ),
        SizedBox(
          width: 80,
          height: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [Text("剩余：${_timeRemain.toInt()}秒")],
          ),
        ),
      ],
    );
  }
}
