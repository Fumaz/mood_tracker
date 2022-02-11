import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:mood_tracker/app/pages/home_page.dart';

class MoodTrackerApp extends StatelessWidget {
  const MoodTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      key: key,
      theme: const CupertinoThemeData(primaryColor: CupertinoColors.systemPink),
      home: const MoodTrackerHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

bool isDarkMode() {
  return SchedulerBinding.instance!.window.platformBrightness == Brightness.dark;
}