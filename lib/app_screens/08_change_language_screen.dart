import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChangeLanguageScreen extends StatefulWidget {
  const ChangeLanguageScreen({super.key});

  @override
  _ChangeLanguageScreenState createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  @override
  Widget build(BuildContext context) {
    Locale locale = Locale('en', 'US'); // 초기값

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.setLanguage),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, locale);
          return false;
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      locale = Locale('ko', 'KR');
                    });
                    Navigator.pop(context, locale);
                  },
                  child: Text("한국어")
              ),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      locale = Locale('en', 'US');
                    });
                    Navigator.pop(context, locale);
                  },
                  child: Text("English")
              ),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      locale = Locale('ar', 'AR');
                    });
                    Navigator.pop(context, locale);
                  },
                  child: Text("اَلْعَرَبِيَّةُ")
              ),
            ],
          ),
        ),
      ),
    );
  }
}
