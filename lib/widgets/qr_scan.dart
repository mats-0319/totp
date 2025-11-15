import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../widgets/app_bar.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key, required this.emitCode});

  final Function(String) emitCode;

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  Barcode? _code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: subpageAppBar(context, "扫描密钥"),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onHandleQRCode),
          Container(
            height: 100,
            padding: EdgeInsets.all(20),
            alignment: Alignment.topLeft,
            decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.4)),
            child: Text(
              "扫描结果：${_code?.displayValue ?? ''}",
              style: TextStyle(color: Colors.white),
              textScaler: TextScaler.linear(1.2),
            ),
          ),
        ],
      ),
    );
  }

  void _onHandleQRCode(BarcodeCapture code) {
    if (!mounted || _code == code.barcodes.firstOrNull) {
      return;
    }

    setState(() {
      _code = code.barcodes.firstOrNull;
    });

    widget.emitCode(_code?.displayValue ?? "");
    // will close dialog in preview page,
    // 尝试过常规路由返回、默认leading组建的scaffold.closeDrawer，都不行，
    // 只能由用户点击返回按钮
    // Navigator.of(context).pop();
  }
}
