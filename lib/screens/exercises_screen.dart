import 'package:flutter/material.dart';
import '../database/database.dart';
import '../main.dart';
import '../utils/exercise_icons.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  List<Exercise> exercises = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadExercises();
  }

  Future<void> loadExercises() async {
    final data = await database.select(database.exercises).get();
    setState(() {
      exercises = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Exercises Library'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : exercises.isEmpty
          ? const Center(child: Text('No exercises found'))
          : ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(
                  Icons.favorite,
                  color: Colors.white,
                ),
              ),
              title: Text(
                exercise.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: [
                  Icon(
                    ExerciseIcons.getEquipmentIcon(exercise.equipment),
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text('${exercise.muscleGroup} • ${exercise.equipment}'),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showExerciseDetails(context, exercise);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  void showExerciseDetails(BuildContext context, Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Muscle Group: ${exercise.muscleGroup}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Equipment: ${exercise.equipment}'),
            const SizedBox(height: 16),
            if (exercise.description != null) Text(exercise.description!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}