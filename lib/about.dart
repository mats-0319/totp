import 'package:flutter/material.dart';
import 'package:totp/widgets/transition_builder.dart';
import 'package:totp/doc.dart';
import 'package:totp/widgets/app_bar_subpages.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: subpageAppBar(context, "关于我们"),
      body: Center(
        child: Column(
          children: [
            _Logo(),
            _AppInfo(),
            _DocItem(name: "使用手册", filename: "assets/manual.md"),
            _DocItem(name: "技术文档", filename: "assets/tech.md"),
            _Copyright(),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      margin: EdgeInsets.only(top: 120, bottom: 20),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 1,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
        image: DecorationImage(
          image: AssetImage("assets/avatar_256.jpg"),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _AppInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("TOTP", textScaler: TextScaler.linear(1.8)),
        SizedBox(height: 10),
        Text(
          "v1.0.0",
          textScaler: TextScaler.linear(1.2),
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 100),
      ],
    );
  }
}

class _DocItem extends StatelessWidget {
  const _DocItem({required this.name, required this.filename});

  final String name;
  final String filename;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 50,
      margin: EdgeInsets.only(bottom: 20),
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  DocPage(title: name, filename: filename),
              transitionsBuilder: transition,
            ),
          );
        },
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          side: WidgetStateProperty.all(
            BorderSide(width: 1, color: Colors.grey),
          ),
          backgroundColor: WidgetStateProperty.all(Colors.white),
        ),
        child: Text(name, textScaler: TextScaler.linear(1.4)),
      ),
    );
  }
}

class _Copyright extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Text(
            "开发者：马同帅",
            textScaler: TextScaler.linear(1.2),
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            "代码地址：github.com/mats0319/totp",
            textScaler: TextScaler.linear(0.8),
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            "All Rights Reserved",
            textScaler: TextScaler.linear(0.8),
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
