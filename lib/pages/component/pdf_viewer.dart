import 'package:flutter/material.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:jlf_mobile/globals.dart' as globals;

class PdfViewerPage extends StatefulWidget {
  final String title;
  final PDFDocument document;

  PdfViewerPage({Key key, @required this.title, @required this.document})
      : super(key: key);
  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: globals.myText(text: widget.title, color: "light", size: 18, weight: "SB"),
      ),
      body: Center(child: PDFViewer(document: widget.document)),
    );
  }
}
