import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totp/model/totp_key_list.dart';
import 'package:totp/pages/home.dart';
import 'package:totp/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        title: "TOTP",
        theme: defaultThemeData(),
        home: const HomePage(),
      ),
    );
  }
}
