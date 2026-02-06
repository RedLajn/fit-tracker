import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import '../database/database.dart';
import '../main.dart';
import 'workout_session_screen.dart';


class StartWorkoutScreen extends StatefulWidget {
  const StartWorkoutScreen({super.key});

  @override
  State<StartWorkoutScreen> createState() => _StartWorkoutScreenState();
}

class _StartWorkoutScreenState extends State<StartWorkoutScreen> {
  List<WorkoutPlan> plans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPlans();
  }

  Future<void> loadPlans() async {
    final data = await database.select(database.workoutPlans).get();
    setState(() {
      plans = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Start Workout'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : plans.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No workout plans available',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Create a plan first'),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () => startWorkout(plan),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.fitness_center,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (plan.description != null)
                                Text(
                                  plan.description!,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Icon(Icons.play_arrow, size: 32),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> startWorkout(WorkoutPlan plan) async {
    final exercises = await (database.select(database.workoutExercises)
      ..where((tbl) => tbl.workoutPlanId.equals(plan.id))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]))
        .get();

    if (!mounted) return;

    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This plan has no exercises')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutSessionScreen(
          plan: plan,
          exercises: exercises,
        ),
      ),
    );
  }
}