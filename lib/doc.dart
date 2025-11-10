import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:totp/widgets/app_bar_subpages.dart';

class DocPage extends StatefulWidget {
  const DocPage({super.key, required this.title, required this.filename});

  final String title;
  final String filename;

  @override
  State<DocPage> createState() => _DocPageState();
}

class _DocPageState extends State<DocPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: subpageAppBar(context, widget.title),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20, left: 40, right: 40),
        child: FutureBuilder(
          future: rootBundle.loadString(widget.filename),
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
