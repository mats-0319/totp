import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:totp/dart/result.dart';
import 'package:totp/dart/totp.dart';
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

  String scanStr = "";
  String err = "";
  bool _isPausing = false;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> _onHandleQRCode(BarcodeCapture code) async {
    var scanStrNullable = code.barcodes.first.rawValue;
    if (scanStrNullable == null) {
      return; // ignore meaning-less scan
    }

    err = "";

    var res = isValidScanStr(scanStrNullable);
    switch (res) {
      case Success():
        scanStr = res.data;

        await _controller.pause();
        _isPausing = true;

        widget.emitCode(scanStr);
      case Failure():
        err = res.err;
        setState(() {});
    }

    setState(() {});
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
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.4)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "扫描结果：$scanStr",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                ?_error(),
                ?_restartScan(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _error() {
    if (err.isNotEmpty) {
      return Text(
        err,
        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
      );
    }

    return null;
  }

  Widget? _restartScan() {
    if (_isPausing) {
      return ElevatedButton(
        onPressed: () async {
          await _controller.start();
          _isPausing = false;
        },
        child: Text("继续扫描"),
      );
    }

    return null;
  }
}

Result<String> isValidScanStr(String str) {
  // 'otpauth://' uri
  if (str.startsWith("otpauth://totp/")) {
    RegExp re = RegExp(r'\?secret=(\w+)');
    final match = re.firstMatch(str);
    if (match != null) {
      str = match.group(1)!;
    }
  }

  // raw base32 key & key parsed from standard uri
  var res = normalize(str);
  if (res is Success) {
    return res;
  }

  return Failure(err: "无效的TOTP key：$str");
}
