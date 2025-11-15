import 'package:flutter/material.dart';
import 'package:totp/instance_manage.dart';
import 'package:totp/model/totp_key_list.dart';

import 'doc.dart';
import 'widgets/app_bar.dart';
import 'widgets/transition_builder.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: subpageAppBar(context, "关于我们"),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 120),
            _Logo(),
            SizedBox(height: 20),
            Text("TOTP", style: Theme.of(context).textTheme.displayMedium),
            SizedBox(height: 10),
            Text("v1.0.0", style: Theme.of(context).textTheme.labelLarge),
            SizedBox(height: 80),
            _ButtonToNewPage(name: "使用手册", page: DocPage(index: 0)),
            SizedBox(height: 8),
            _ButtonToNewPage(name: "技术文档", page: DocPage(index: 1)),
            SizedBox(height: 8),
            _ButtonToNewPage(name: "实例管理", page: InstanceManagePage()),
            SizedBox(height: 40),
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
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: Container(
              width: 300,
              constraints: BoxConstraints(maxHeight: 600),
              padding: EdgeInsets.all(40),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    TOTPKeyList().display(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          image: DecorationImage(
            image: AssetImage("assets/avatar_256.jpg"),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _ButtonToNewPage extends StatelessWidget {
  const _ButtonToNewPage({required this.name, required this.page});

  final String name;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 50,
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => page,
              transitionsBuilder: transition,
            ),
          );
        },
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          backgroundColor: WidgetStateProperty.all(
            Theme.of(context).colorScheme.onSurface,
          ),
        ),
        child: Text(name),
      ),
    );
  }
}

class _Copyright extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("开发者：马同帅", style: Theme.of(context).textTheme.labelMedium),
        Text(
          "代码地址：github.com/mats0319/totp",
          style: Theme.of(context).textTheme.labelSmall,
        ),
        Text(
          "All Rights Reserved",
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
