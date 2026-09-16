import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:totp/dart/result.dart';
import 'package:totp/dart/scan_str.dart';
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
    _controller.dispose();
    super.dispose();
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
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  style: TextStyle(color: theme.colorScheme.tertiary),
                ),
                ?_error(theme),
                ?_restartScan(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _error(ThemeData theme) {
    return err.isNotEmpty
        ? Text(err, style: TextStyle(color: theme.colorScheme.tertiary))
        : null;
  }

  Widget? _restartScan() {
    return _isPausing
        ? ElevatedButton(
            onPressed: () async {
              await _controller.start();
              setState(() => _isPausing = false);
            },
            child: Text("继续扫描"),
          )
        : null;
  }
}
