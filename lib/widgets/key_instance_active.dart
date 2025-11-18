import 'dart:async';
import 'package:flutter/material.dart';

import 'package:totp/theme.dart';
import 'package:totp/dart/totp.dart';
import 'package:totp/model/totp_key.dart';

class ActiveKeyInstance extends StatelessWidget {
  const ActiveKeyInstance({
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
          _nameBar(),
          _TimeBasedProgress(keyStr: keyIns.key),
        ],
      ),
    );
  }

  Widget _nameBar() {
    return Row(
      children: [
        Text(keyIns.name, style: blackText(2)),
        Spacer(),
        ElevatedButton(
          onPressed: () => emitStatus(false),
          child: Text("静默", style: blackText(-1)),
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
  String totpStr = "";
  double timeRemain = 0.0;

  @override
  void initState() {
    super.initState();

    _timerIns = Timer.periodic(Duration(milliseconds: 100), (timer) {
      timeRemain -= 0.1;
      if (timeRemain <= 0) {
        var (totpStr_, timeRemain_) = generateTOTP(widget.keyStr);
        totpStr = totpStr_;
        timeRemain = timeRemain_;
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
              value: timeRemain / 30,
              color: Theme.of(context).colorScheme.secondary,
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
          ),
          Text(totpStr, style: blackText(2)),
          SizedBox(
            width: double.infinity,
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("剩余：${timeRemain.toInt()}秒", style: blackText(-2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
