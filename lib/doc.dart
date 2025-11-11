import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';

import 'widgets/subpages_app_bar.dart';

class DocPage extends StatelessWidget {
  const DocPage({super.key, required this.title, required this.filename});

  final String title;
  final String filename;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: subpageAppBar(context, title),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20, left: 40, right: 40),
        child: FutureBuilder(
          future: rootBundle.loadString(filename),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return MarkdownWidget(data: snapshot.data);
            } else {
              return Center(child: Text("加载中......"));
            }
          },
        ),
      ),
    );
  }
}
