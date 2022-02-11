import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mood_tracker/app/pages/home_page.dart';
import 'package:mood_tracker/database/database.dart';

import '../app.dart';

class MoodTrackerHomeState extends State<MoodTrackerHomePage> {
  DateTime _selectedDate = DateTime.now();
  Mood mood = Mood.unknown;
  String? note;

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
        FixedExtentScrollController(initialItem: 3);

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
              color: isDarkMode() ? CupertinoColors.black : CupertinoColors.systemBackground,
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
            title: const Text('Note'),
            content: CupertinoTextField(
              minLines: 10,
              maxLines: 20,
              controller: TextEditingController(text: note),
              onChanged: (value) {
                note = value;
              },
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    selectDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: GestureDetector(
          onTap: () =>
              selectDate(_selectedDate.subtract(const Duration(days: 1))),
          child: const Icon(CupertinoIcons.back),
        ),
        middle: GestureDetector(
          child: Text(DateFormat('MMMM d').format(_selectedDate)),
          onTap: () => selectDatePopup(),
        ),
        trailing: GestureDetector(
          onTap: () => selectDate(_selectedDate.add(const Duration(days: 1))),
          child: const Icon(CupertinoIcons.forward),
        ),
      ),
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
              child: Text(getEmoji(mood),
                  style: const TextStyle(fontSize: 175)),
            )
          ]),
          Text(
              mood == Mood.unknown
                  ? "You haven't recorded your mood today."
                  : "Today you are feeling " +
                      mood.toString().split('.').last +
                      "!",
              style: TextStyle(fontSize: 20,
              color: isDarkMode() ? Colors.white : Colors.black)),
          CupertinoButton(
              child: Text(
                "Click to " + ((note == null) ? "add" : "view") + " notes",
                style: const TextStyle(fontSize: 20),
              ),
              onPressed: () => viewNotePopup())
        ],
      ),
    );
  }
}
