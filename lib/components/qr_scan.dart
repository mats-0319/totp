import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:totp/widgets/app_bar.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key, required this.emitCode});

  final Function(String) emitCode;

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  String res = "";

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> _onHandleQRCode(BarcodeCapture code) async {
    var resNullable = code.barcodes.first.rawValue;
    if (resNullable == null || resNullable == res) {
      return; // ignore meaning-less scan and duplicate scan
    }

    // 扫描到一个新的结果不暂停

    res = resNullable;

    setState(() {});

    widget.emitCode(res);
    // will close dialog in preview page,
    // 尝试过常规路由返回、默认leading组建的scaffold.closeDrawer，都不行，
    // 只能由用户点击返回按钮
    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: subpageAppBar(context, "扫描密钥"),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onHandleQRCode),
          Container(
            height: 100,
            padding: EdgeInsets.all(20),
            alignment: Alignment.topLeft,
            decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.4)),
            child: Text(
              "扫描结果：$res",
              style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
            ),
          ),
        ],
      ),
    );
  }
}
