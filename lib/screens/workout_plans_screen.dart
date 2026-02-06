import 'package:flutter/material.dart';
import '../database/database.dart';
import '../main.dart';
import 'create_workout_plan_screen.dart';

class WorkoutPlansScreen extends StatefulWidget {
  const WorkoutPlansScreen({super.key});

  @override
  State<WorkoutPlansScreen> createState() => _WorkoutPlansScreenState();
}

class _WorkoutPlansScreenState extends State<WorkoutPlansScreen> {
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
        title: const Text('Workout Plans'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : plans.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No workout plans yet',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Tap + to create your first plan'),
          ],
        ),
      )
          : ListView.builder(
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 28,
                ),
              ),
              title: Text(
                plan.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(plan.description ?? 'No description'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateWorkoutPlanScreen()),
          );
          loadPlans();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}