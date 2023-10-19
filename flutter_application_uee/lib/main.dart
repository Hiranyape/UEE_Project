import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_uee/auth/auth.dart';
import 'package:flutter_application_uee/auth/login_or_register.dart';
import 'package:flutter_application_uee/firebase_options.dart';
import 'package:flutter_application_uee/pages/start_page.dart';
import 'package:flutter_application_uee/pages/user_login_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_application_uee/l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartPage(),
      supportedLocales: L10n.all,
      locale: Locale('si'),
      localizationsDelegates: const {
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      },
    );
  }
}
