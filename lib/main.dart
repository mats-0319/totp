import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totp/model/totp_key_list.dart';
import 'package:totp/model/totp_key.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TOTPKeyList().create(TOTPKey("HFLEOZBUOVKXMVRY", "name1", false)); // todo: for test
  await TOTPKeyList().create(TOTPKey("MVIHMVLNMI3EMVTW", "name2", true)); // todo: for test
  await TOTPKeyList().create(TOTPKey.all("key3", "name3", false, true)); // todo: for test
  await TOTPKeyList().initialize();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TOTPKeyList(),
      child: MaterialApp(
        title: 'TOTP App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const HomePage(),
      ),
    );
  }
}
