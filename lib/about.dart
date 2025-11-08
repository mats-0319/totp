import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(child: Text("关于我们")),
        actions: [
          IconTheme(data: IconThemeData(size: 40,opacity: 0), child: Icon(Icons.add)),
        ],
      ),
      body: Center(),
    );
  }
}