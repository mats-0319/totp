import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:totp/widgets/app_bar.dart';

enum DocItemE {
  manual(name: "使用手册", path: "doc/manual.md"),
  tech(name: "技术文档", path: "doc/tech.md");

  const DocItemE({required this.name, required this.path});

  final String name;
  final String path;
}

class DocPage extends StatelessWidget {
  const DocPage({super.key, required this.docIns});

  final DocItemE docIns;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: subpageAppBar(context, docIns.name),
      body: Padding(
        padding: EdgeInsets.all(40),
        child: FutureBuilder(
          future: rootBundle.loadString(docIns.path),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return MarkdownWidget(data: snapshot.data);
            } else if (snapshot.hasError) {
              return Center(child: Text("加载失败：${snapshot.error.toString()}"));
            } else {
              return Center(child: Text("加载中......"));
            }
          },
        ),
      ),
    );
  }
}
