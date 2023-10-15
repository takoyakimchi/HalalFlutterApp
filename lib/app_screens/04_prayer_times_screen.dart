// 이슬람교의 5회 기도 시간을 표시하는 화면
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  _PrayerTimesScreenState createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.btnPrayerTimes),
      ),
      body: Center(
        child: Container(
            child: Column(
              children: const [
                Text("Prayer Times Screen"),
                Text("Hello!"),
              ],
            )
        ),
      ),
    );
  }
}
