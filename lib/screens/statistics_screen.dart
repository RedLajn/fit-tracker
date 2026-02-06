import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../database/database.dart';
import '../main.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<WorkoutSession> sessions = [];
  int totalWorkouts = 0;
  int totalExercises = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    final allSessions = await (database.select(database.workoutSessions)
      ..where((tbl) => tbl.completedAt.isNotNull())
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.startedAt)]))
        .get();

    int exerciseCount = 0;
    for (var session in allSessions) {
      final exercises = await (database.select(database.sessionExercises)
        ..where((tbl) => tbl.sessionId.equals(session.id)))
          .get();
      exerciseCount += exercises.length;
    }

    setState(() {
      sessions = allSessions;
      totalWorkouts = allSessions.length;
      totalExercises = exerciseCount;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Statistics'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : sessions.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No workout data yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            const Text('Complete a workout to see statistics'),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total Workouts',
                    value: totalWorkouts.toString(),
                    icon: Icons.fitness_center,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Total Exercises',
                    value: totalExercises.toString(),
                    icon: Icons.accessibility_new,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Workouts Over Time',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: WorkoutChart(sessions: sessions),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Workouts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final duration = session.completedAt != null
                    ? session.completedAt!.difference(session.startedAt)
                    : Duration.zero;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                      Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.check, color: Colors.white),
                    ),
                    title: Text(
                      DateFormat('MMM dd, yyyy').format(session.startedAt),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Duration: ${duration.inMinutes} minutes',
                    ),
                    trailing: Text(
                      DateFormat('HH:mm').format(session.startedAt),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutChart extends StatelessWidget {
  final List<WorkoutSession> sessions;

  const WorkoutChart({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final last7Days = List.generate(7, (index) {
      return DateTime.now().subtract(Duration(days: 6 - index));
    });

    final workoutsByDay = <DateTime, int>{};
    for (var day in last7Days) {
      workoutsByDay[DateTime(day.year, day.month, day.day)] = 0;
    }

    for (var session in sessions) {
      final sessionDay = DateTime(
        session.startedAt.year,
        session.startedAt.month,
        session.startedAt.day,
      );
      if (workoutsByDay.containsKey(sessionDay)) {
        workoutsByDay[sessionDay] = workoutsByDay[sessionDay]! + 1;
      }
    }

    final spots = workoutsByDay.entries.map((entry) {
      final dayIndex =
      last7Days.indexWhere((d) => DateTime(d.year, d.month, d.day) == entry.key);
      return FlSpot(dayIndex.toDouble(), entry.value.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < last7Days.length) {
                  return Text(
                    DateFormat('E').format(last7Days[value.toInt()]),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}