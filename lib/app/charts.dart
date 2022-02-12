import 'package:charts_flutter/flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:mood_tracker/database/database.dart';

class SimpleTimeSeriesChart extends StatelessWidget {
  final List<Series<dynamic, DateTime>> series;
  final bool animate;

  const SimpleTimeSeriesChart(this.series, {required this.animate});

  @override
  Widget build(BuildContext context) {
    return TimeSeriesChart(
      series,
      animate: animate,
      defaultRenderer: LineRendererConfig(
        includePoints: true,
        includeArea: true,
      ),
      primaryMeasureAxis: NumericAxisSpec(
        showAxisLine: false,
        tickProviderSpec: StaticNumericTickProviderSpec([
          for (Mood mood in Mood.values.reversed)
            if (mood != Mood.unknown)
              TickSpec(
                Mood.values.length - mood.index,
                label: getEmoji(mood),
                style: const TextStyleSpec(
                  fontSize: 20,
                ),
              ),
        ]),
      ),
    );
  }

  static Future<List<Series<Day, DateTime>>> createSeries() async {
    final data = await last(7);

    return [
      Series(
        id: 'Mood',
        colorFn: (day, __) => ColorUtil.fromDartColor(getColor(day.mood!)),
        domainFn: (Day day, _) => day.dateTime,
        measureFn: (Day day, _) => Mood.values.length - day.mood!.index,
        data: data,
      ),
    ];
  }
}
