import 'dart:convert';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kaminari/record.dart';
import 'package:quiver/iterables.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kaminari"),
      ),
      body: FutureBuilder<List<RecordInterval>>(
        future: () async {
          final now = (DateTime.now().millisecondsSinceEpoch / 1000).round();

          final uri = Uri(
            scheme: "http",
            host: "172.24.0.6",
            port: 8000,
            path: "/values",
            queryParameters: {
              "from": (((now - (3600 * 24)) / 3600).round() * 3600).toString(),
              "to": now.toString(),
            },
          );

          final res = await http.get(uri);
          final json = jsonDecode(res.body) as List<dynamic>;
          final records = json.map((e) => Record.fromJson(e));
          final intervals = zip([
            records.take(records.length - 1),
            records.skip(1),
          ]).map((e) => RecordInterval(e.first, e.last)).toList();

          final merged = partition(intervals, 6 * 10 * 2)
              .map((e) => e.first.merge(e.last))
              .toList();

          print(merged);

          return merged;
        }(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          if (snapshot.hasData) {
            final textStyle = Theme.of(context).textTheme.bodyText2!;

            return Column(
              children: [
                Container(
                  height: 400,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 24,
                    ),
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: snapshot.data!.fold(
                            100, (acc, e) => math.max(acc!, e.average + 100)),
                        gridData: FlGridData(
                          drawHorizontalLine: true,
                          drawVerticalLine: true,
                          horizontalInterval: 100,
                          getDrawingHorizontalLine: (y) =>
                              FlLine(color: Colors.grey.withOpacity(0.1)),
                          verticalInterval: 3600 * 4,
                          getDrawingVerticalLine: (y) =>
                              FlLine(color: Colors.grey.withOpacity(0.1)),
                        ),
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            fitInsideVertically: true,
                            getTooltipItems: (touchedSpots) => [
                              LineTooltipItem(
                                  DateFormat.Hm().format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              touchedSpots.first.x.toInt() *
                                                  1000)) +
                                      "\n${touchedSpots.first.y.round()}W",
                                  textStyle.copyWith(
                                    color: Colors.red,
                                  )),
                            ],
                          ),
                        ),
                        titlesData: FlTitlesData(
                            leftTitles: SideTitles(
                              showTitles: true,
                              interval: 100,
                              getTextStyles: (value) {
                                return textStyle;
                              },
                              margin: 10,
                            ),
                            bottomTitles: SideTitles(
                              showTitles: true,
                              interval: 3600 * 4,
                              getTextStyles: (value) =>
                                  Theme.of(context).textTheme.bodyText2!,
                              getTitles: (timestamp) => DateFormat.Hm().format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      timestamp.toInt() * 1000)),
                            )),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (final interval in snapshot.data!)
                                FlSpot(interval.start.timestamp * 1.0,
                                    interval.average),
                            ],
                            isCurved: true,
                            preventCurveOverShooting: true,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => null,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
