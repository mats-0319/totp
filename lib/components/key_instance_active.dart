import 'dart:async';

import 'package:flutter/material.dart';
import 'package:totp/dart/result.dart';
import 'package:totp/dart/totp.dart';
import 'package:totp/model/totp_key.dart';
import 'package:totp/theme.dart';
import 'package:totp/widgets/print_alert.dart';

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
          SizedBox(height: 20),
          _TimeBasedProgress(keyBase32: keyIns.key, onActiveFailed: emitStatus),
        ],
      ),
    );
  }

  Widget _nameBar() {
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: Text(
            keyIns.name,
            style: blackText(1),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
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
  const _TimeBasedProgress({
    required this.keyBase32,
    required this.onActiveFailed,
  });

  final String keyBase32;
  final Function(bool) onActiveFailed;

  @override
  State<_TimeBasedProgress> createState() => _TimeBasedProgressState();
}

class _TimeBasedProgressState extends State<_TimeBasedProgress> {
  late Timer _timerIns;
  String totpCode = "";
  double timeRemain = 0.0;

  // 当前 totpCode 所属的时间窗口序号，-1 表示还没有计算过
  int _timeStep = -1;

  @override
  void didUpdateWidget(covariant _TimeBasedProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.keyBase32 != widget.keyBase32) {
      _timeStep = -1; // key 变了，强制重算，避免继续显示上一个 key 的验证码
      maintainTOTPCode();
    }
  }

  @override
  void initState() {
    super.initState();

    // 先算一次，否则第一帧只能显示空验证码；此时还没 build，不需要 setState
    maintainTOTPCode(notify: false);
    _timerIns = Timer.periodic(
      Duration(milliseconds: 100),
      (_) => maintainTOTPCode(),
    );
  }

  void maintainTOTPCode({bool notify = true}) {
    if (!mounted) {
      return;
    }

    // 每次重新读时钟计算，可以避免APP切后台时计时器暂停/计时器抖动等原因导致的误差
    final now = DateTime.now();
    const int intervalMs = totpTimeInterval * 1000;
    timeRemain = (intervalMs - now.millisecondsSinceEpoch % intervalMs) / 1000;

    // 只在跨入新的时间窗口时重新计算：直接判断 second/millisecond 会被定时器抖动漏掉
    final int step = now.millisecondsSinceEpoch ~/ intervalMs;
    if (step != _timeStep) {
      _timeStep = step;

      var res = generateTOTP(widget.keyBase32);
      switch (res) {
        case Success():
          totpCode = res.data;
        case Failure():
          totpCode = "";
          // key 非法：提示后退回静默状态。这里可能是 initState 触发的，
          // 不能同步 showDialog/setState 父级，放到当前帧结束后处理
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            printAlert(context, res.err);
            widget.onActiveFailed(false);
          });
          return;
      }
    }

    if (notify) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _timerIns.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: timeRemain / totpTimeInterval,
          color: Theme.of(context).colorScheme.secondary,
          backgroundColor: Theme.of(context).colorScheme.surface,
          constraints: BoxConstraints.tightFor(width: 150, height: 150),
        ),
        Text(totpCode, style: blackText(2)),
        SizedBox(
          width: double.infinity,
          height: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [Text("剩余：${timeRemain.toInt()}秒", style: blackText(-2))],
          ),
        ),
      ],
    );
  }
}
