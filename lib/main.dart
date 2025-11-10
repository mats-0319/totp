import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totp/model/totp_key_list.dart';
import 'package:totp/model/totp_key.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TOTPKeyList().initialize();
  await _addDemoKeyIns();

  runApp(const App());
}

Future<void> _addDemoKeyIns() async {
  bool hasValidItemFlag = false;
  for (var i = 0; i < TOTPKeyList().list.length; i++) {
    if (!TOTPKeyList().list[i].isDeleted) {
      hasValidItemFlag = true;
      break;
    }
  }
  if (hasValidItemFlag) {
    await TOTPKeyList().create(TOTPKey("HFLEOZBUOVKXMVRY", "demo", false));
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
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const HomePage(),
      ),
    );
  }
}
