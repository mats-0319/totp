import 'package:flutter/material.dart';
import 'package:totp/pages/doc.dart';
import 'package:totp/pages/instance_manage.dart';
import 'package:totp/widgets/app_bar.dart';
import 'package:totp/widgets/new_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: subpageAppBar(context, "关于我们"),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 120),
            _logo(),
            SizedBox(height: 40),
            Text("T O T P", style: theme.textTheme.headlineMedium),
            SizedBox(height: 10),
            Text("v1.0.0", style: theme.textTheme.labelLarge),
            SizedBox(height: 70),
            _ButtonToNewPage(
              name: "使用手册",
              page: DocPage(docIns: DocItemE.manual),
            ),
            _ButtonToNewPage(
              name: "技术文档",
              page: DocPage(docIns: DocItemE.tech),
            ),
            _ButtonToNewPage(name: "实例管理", page: InstanceManagePage()),
            SizedBox(height: 40),
            Text("开发者：马同帅", style: theme.textTheme.displayMedium),
            Text(
              "代码地址：github.com/mats0319/totp",
              style: theme.textTheme.displaySmall,
            ),
            Text("All Rights Reserved", style: theme.textTheme.displaySmall),
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        image: DecorationImage(
          image: AssetImage("assets/logo_256.png"),
          fit: BoxFit.contain,
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
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsetsGeometry.only(top: 4, bottom: 4),
      width: 300,
      height: 60,
      child: ElevatedButton(
        onPressed: newPage(context, page),
        style: OutlinedButton.styleFrom(
          backgroundColor: theme.colorScheme.onSurface,
        ),
        child: Text(name, style: theme.textTheme.labelLarge),
      ),
    );
  }
}
