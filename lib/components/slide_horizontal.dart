import 'package:flutter/material.dart';

class Slide extends StatefulWidget {
  Key keyStr;
  List<Widget> actions;
  Widget child;
  double actionsWidth;

  Slide({
    required this.keyStr,
    required this.child,
    required this.actionsWidth,
    required this.actions,
  }) : super(key: keyStr);

  @override
  State<StatefulWidget> createState() => _Slide();
}

class _Slide extends State<Slide> with TickerProviderStateMixin {
  double translateX = 0;

  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(
          lowerBound: -widget.actionsWidth,
          upperBound: 0,
          vsync: this,
          duration: Duration(milliseconds: 300),
        )..addListener(() {
          translateX = animationController.value;
          setState(() {});
        });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: widget.actions,
          ),
        ),
        GestureDetector(
          onHorizontalDragUpdate: (v) {
            onHorizontalDragUpdate(v);
          },
          onHorizontalDragEnd: (v) {
            onHorizontalDragEnd(v);
          },
          child: Transform.translate(
            offset: Offset(translateX, 0),
            child: Row(
              children: <Widget>[Expanded(flex: 1, child: widget.child)],
            ),
          ),
        ),
      ],
    );
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    translateX = (translateX + details.delta.dx).clamp(
      -widget.actionsWidth,
      0.0,
    );
    setState(() {});
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    animationController.value = translateX;
    if (details.velocity.pixelsPerSecond.dx > 200) {
      close();
    } else if (details.velocity.pixelsPerSecond.dx < -200) {
      open();
    } else {
      if (translateX.abs() > widget.actionsWidth / 2) {
        open();
      } else {
        close();
      }
    }
  }

  void open() {
    if (translateX != -widget.actionsWidth)
      animationController.animateTo(-widget.actionsWidth);
  }

  void close() {
    if (translateX != 0) animationController.animateTo(0);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
