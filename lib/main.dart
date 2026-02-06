import 'package:flutter/material.dart';
import 'database/database.dart';
import 'database/seed_data.dart';
import 'screens/exercises_screen.dart';
import 'screens/workout_plans_screen.dart';
import 'screens/start_workout_screen.dart';
import 'screens/statistics_screen.dart';

late AppDatabase database;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  database = AppDatabase();
  await seedDatabase(database);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('FitTracker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to FitTracker!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkoutPlansScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 48),
              ),
              icon: const Icon(Icons.list_alt),
              label: const Text('My Workouts'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StartWorkoutScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 48),
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Training'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 48),
              ),
              icon: const Icon(Icons.bar_chart),
              label: const Text('Statistics'),
            ),
          ],
        ),
      ),
    );
  }
}