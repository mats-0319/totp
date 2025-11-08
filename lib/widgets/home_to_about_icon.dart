import 'package:flutter/material.dart';
import 'package:totp/about.dart';

class HomeToAboutIcon extends StatelessWidget {
  const HomeToAboutIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: _routeToAboutPage,
            transitionsBuilder: _transition,
          ),
        );
      },
      icon: Icon(Icons.apps),
    );
  }
}

var _routeToAboutPage = (context, animation, secondaryAnimation) =>
    const AboutPage();

var _transition = (context, animation, secondaryAnimation, child) {
  return SlideTransition(
    position: animation.drive(Tween(begin: Offset(1.0, 0.0), end: Offset.zero)),
    child: child,
  );
};
