import 'package:flutter/material.dart';
import 'package:first_flutter_app/landingpage.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final GlobalKey<_MyAppState> myAppStateKey = GlobalKey<_MyAppState>();
// Locale _locale = Locale.fromSubtags(languageCode: 'ko');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: 'assets/config/.env'); // load .env file
  runApp(MyApp(key: myAppStateKey));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // locale: _locale,
      title: 'main.dart',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ko'), // Korean
        Locale('ar'), // Arabic
      ],
      home: LandingPage(),
    );
  }
}
