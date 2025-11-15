import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totp/theme.dart';

import 'home.dart';
import 'model/totp_key.dart';
import 'model/totp_key_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TOTPKeyList().initialize();
  await _addDemoKeyIns();

  runApp(const App());
}

Future<void> _addDemoKeyIns() async {
  if (TOTPKeyList().list.isEmpty) {
    // base32 of 'mario'
    await TOTPKeyList().create(TOTPKey("NVQXE2LP", "demo", false));
    await TOTPKeyList().create(TOTPKey("NVQXE2LA", "demo2", true));
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TOTPKeyList(),
      child: MaterialApp(
        title: "TOTP",
        theme: defaultThemeData(),
        home: const HomePage(),
      ),
    );
  }
}
