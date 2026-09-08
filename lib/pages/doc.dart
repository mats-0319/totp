import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';

import 'package:totp/widgets/app_bar.dart';

List<_DocItem> _docFiles = [
  _DocItem("使用手册", "assets/manual.md"),
  _DocItem("技术文档", "assets/tech.md"),
];

class DocPage extends StatelessWidget {
  const DocPage({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    if (!(0 <= index && index < _docFiles.length)) {
      return Center(child: Text("无效的文档编号"));
    }

    _DocItem docItemIns = _docFiles[index];

    return Scaffold(
      appBar: subpageAppBar(context, docItemIns.name),
      body: Padding(
        padding: EdgeInsets.all(40),
        child: FutureBuilder(
          future: rootBundle.loadString(docItemIns.filename),
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

class _DocItem {
  String name = "";
  String filename = "";

  _DocItem(this.name, this.filename);
}
