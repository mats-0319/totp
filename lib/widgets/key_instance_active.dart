import 'dart:async';

import 'package:flutter/material.dart';
import 'package:totp/dart/result.dart';
import 'package:totp/dart/totp.dart';
import 'package:totp/model/totp_key.dart';

class ActiveKeyInstance extends StatelessWidget {
  const ActiveKeyInstance({
    super.key,
    required this.keyIns,
    required this.onChanged,
  });

  final TOTPKey keyIns;
  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _nameBar(context),
        _TimeBasedProgress(keyBase32: keyIns.key, onActiveFailed: onChanged),
      ],
    );
  }

  Widget _nameBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: Text(
              keyIns.name,
              style: theme.textTheme.headlineMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Spacer(),
          ElevatedButton(onPressed: () => onChanged(false), child: Text("静默")),
        ],
      ),
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

    // 只在跨入新的时间窗口时重新计算
    final int step = now.millisecondsSinceEpoch ~/ intervalMs;
    if (step == _timeStep) {
      if (notify) {
        setState(() {});
      }
      return;
    }

    _timeStep = step;

    var res = generateTOTP(widget.keyBase32);
    switch (res) {
      case Success():
        totpCode = res.data;

        if (notify) {
          setState(() {});
        }
      case Failure():
        totpCode = "";
        widget.onActiveFailed(false);
    }
  }

  @override
  void dispose() {
    _timerIns.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: timeRemain / totpTimeInterval,
          color: theme.colorScheme.onSurfaceVariant,
          backgroundColor: theme.colorScheme.surface,
          constraints: BoxConstraints.tightFor(width: 150, height: 150),
        ),
        Text(totpCode, style: theme.textTheme.displayMedium),
        Container(
          height: 150,
          alignment: Alignment.bottomRight,
          child: Text(
            "剩余：${timeRemain.toInt()}秒",
            style: theme.textTheme.labelMedium,
          ),
        ),
      ],
    );
  }
}
