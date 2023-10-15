// qibla 방향(이슬람교 기도 방향)을 표시하는 화면
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QiblaDirectionScreen extends StatefulWidget {
  const QiblaDirectionScreen({super.key});

  @override
  _QiblaDirectionScreenState createState() => _QiblaDirectionScreenState();
}

class _QiblaDirectionScreenState extends State<QiblaDirectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.btnQiblaDirection),
      ),
      body: Container(
          child: Column(
            children: const [
              Text("Qibla Direction Screen"),
              Text("Hello!"),
            ],
          )
      ),
    );
  }
}
