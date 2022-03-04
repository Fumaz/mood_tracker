import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mood_tracker/app/pages/home_page.dart';
import 'package:mood_tracker/database/database.dart';

import '../app.dart';
import '../charts.dart';

class MoodTrackerHomeState extends State<MoodTrackerHomePage>
    with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  Mood mood = Mood.unknown;
  String? note;
  var _controller;

  void selectDate(DateTime date) {
    if (mood != Mood.unknown || note != null) {
      Day d = Day(_selectedDate.day, _selectedDate.month, _selectedDate.year,
          mood: mood, note: note);
      insertDay(d).then((value) => {});
    }

    day(date.day, date.month, date.year).then((day) {
      setState(() {
        _selectedDate = date;
        mood = day.mood ?? Mood.unknown;
        note = day.note;
      });
    });
  }

  void selectMood() {
    FixedExtentScrollController controller =
        FixedExtentScrollController(initialItem: Mood.values.indexOf(mood));

    showCupertinoModalPopup(
        context: context,
        builder: (_) => SizedBox(
            height: 200,
            child: CupertinoPicker(
                scrollController: controller,
                itemExtent: 30,
                onSelectedItemChanged: (index) {
                  setState(() {
                    mood = Mood.values[index];
                  });
                },
                backgroundColor: CupertinoColors.systemBackground,
                children: <Widget>[
                  for (Mood mood in Mood.values)
                    Text(mood.toString().split('.').last + " " + getEmoji(mood))
                ])));
  }

  void selectDatePopup() {
    showCupertinoModalPopup(
        context: context,
        builder: (_) {
          return Container(
              height: 216,
              padding: const EdgeInsets.only(top: 6.0),
              color: isDarkMode()
                  ? CupertinoColors.black
                  : CupertinoColors.systemBackground,
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 22.0,
                ),
                child: GestureDetector(
                  onTap: () {},
                  child: SafeArea(
                    top: false,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: _selectedDate,
                      onDateTimeChanged: (DateTime newDateTime) {
                        selectDate(newDateTime);
                      },
                    ),
                  ),
                ),
              ));
        });
  }

  void viewNotePopup() {
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: const Padding(
                child: Text('Note'), padding: EdgeInsets.only(bottom: 15)),
            content: CupertinoTextField(
              minLines: 10,
              maxLines: 10,
              maxLength: 500,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              controller: TextEditingController(text: note),
              onChanged: (value) {
                if (value.split("\n").length > 10) {
                  value = value.split("\n").sublist(0, 10).join("\n");
                }

                setState(() {
                  note = value;
                });
              },
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('Save'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  void viewAuthorPopup() {
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: const Text("About me"),
            content: const Text("Made with <3 by Fumaz\nv1.693"),
            actions: [
              CupertinoDialogAction(
                child: const Text('Thanks!'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  void viewChartPopup() {
    SimpleTimeSeriesChart.createSeries().then((value) {
      showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: const Text("Last 7 days"),
              content: SizedBox(
                  width: 700,
                  height: 300,
                  child: Column(children: [
                    SizedBox(
                      width: 700,
                      height: 235,
                      child: SimpleTimeSeriesChart(
                        value,
                        animate: true,
                      ),
                    ),
                    CupertinoButton(
                        child: const Text("Close"),
                        onPressed: () {
                          Navigator.pop(context);
                        })
                  ])),
            );
          });
    });
  }

  @override
  void initState() {
    super.initState();
    selectDate(DateTime.now());

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
      setState(() {

        });
    })..animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: GestureDetector(
          onLongPress: () => viewChartPopup(),
          onTap: () =>
              selectDate(_selectedDate.subtract(const Duration(days: 1))),
          child: const Icon(CupertinoIcons.back),
        ),
        middle: GestureDetector(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(DateFormat('MMMM d').format(_selectedDate)),
            const Padding(padding: EdgeInsets.only(left: 10)),
            const Icon(CupertinoIcons.calendar)
          ]),
          onTap: () => selectDatePopup(),
        ),
        trailing: GestureDetector(
          onTap: () => selectDate(_selectedDate.add(const Duration(days: 1))),
          child: const Icon(CupertinoIcons.forward),
        ),
      ),
      child: Transform.translate(
        offset: Offset(100.0 * _controller.value, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectMood();
                  });
                },
                onLongPress: () {
                  viewAuthorPopup();
                },
                child:
                    Text(getEmoji(mood), style: const TextStyle(fontSize: 175)),
              )
            ]),
            Text(
                mood == Mood.unknown
                    ? "Tap to record your mood!"
                    : "You are feeling " +
                        mood.toString().split('.').last +
                        "!",
                style: TextStyle(
                    fontSize: 20,
                    color: isDarkMode() ? Colors.white : Colors.black)),
            CupertinoButton(
                child: const Text(
                  "Click to add notes",
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () => viewNotePopup()),
            if (note != null)
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Text(
                  note!,
                  style: TextStyle(
                      fontSize: 20,
                      color: isDarkMode() ? Colors.white : Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
