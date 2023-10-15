// 라마단 기간을 표시하는 화면
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RamadanInfoScreen extends StatefulWidget {
  const RamadanInfoScreen({super.key});

  @override
  _RamadanInfoScreenState createState() => _RamadanInfoScreenState();
}

class _RamadanInfoScreenState extends State<RamadanInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.btnRamadan),
      ),
      body: Container(
          child: Column(
            children: const [
              Text("Ramadan Info Screen"),
              Text("Hello!"),
            ],
          )
      ),
    );
  }
}
