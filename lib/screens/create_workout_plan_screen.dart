import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database.dart';
import '../main.dart';

class CreateWorkoutPlanScreen extends StatefulWidget {
  const CreateWorkoutPlanScreen({super.key});

  @override
  State<CreateWorkoutPlanScreen> createState() => _CreateWorkoutPlanScreenState();
}

class _CreateWorkoutPlanScreenState extends State<CreateWorkoutPlanScreen> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  List<Exercise> allExercises = [];
  List<WorkoutExerciseData> selectedExercises = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadExercises();
  }

  Future<void> loadExercises() async {
    final data = await database.select(database.exercises).get();
    setState(() {
      allExercises = data;
      isLoading = false;
    });
  }

  Future<void> savePlan() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter plan name')),
      );
      return;
    }

    if (selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one exercise')),
      );
      return;
    }

    final planId = await database.into(database.workoutPlans).insert(
      WorkoutPlansCompanion.insert(
        name: nameController.text,
        description: drift.Value(descriptionController.text),
      ),
    );

    for (var i = 0; i < selectedExercises.length; i++) {
      final exercise = selectedExercises[i];
      await database.into(database.workoutExercises).insert(
        WorkoutExercisesCompanion.insert(
          workoutPlanId: planId,
          exerciseId: exercise.exerciseId,
          sets: exercise.sets,
          reps: exercise.reps,
          weight: drift.Value(exercise.weight),
          restSeconds: exercise.restSeconds,
          orderIndex: i,
        ),
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Create Workout Plan'),
        actions: [
          IconButton(
            onPressed: savePlan,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Plan Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Exercises',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => showAddExerciseDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exercise'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (selectedExercises.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No exercises added yet'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedExercises.length,
                itemBuilder: (context, index) {
                  final item = selectedExercises[index];
                  final exercise = allExercises.firstWhere((e) => e.id == item.exerciseId);
                  return Card(
                    child: ListTile(
                      leading: Text('${index + 1}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      title: Text(exercise.name),
                      subtitle: Text('${item.sets} sets × ${item.reps} reps • ${item.weight ?? 0} kg • Rest: ${item.restSeconds}s'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            selectedExercises.removeAt(index);
                          });
                        },
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

  void showAddExerciseDialog() {
    Exercise? selectedExercise;
    int sets = 3;
    int reps = 10;
    double? weight = 0;
    int rest = 60;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Exercise'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Exercise>(
                  decoration: const InputDecoration(labelText: 'Exercise'),
                  value: selectedExercise,
                  items: allExercises
                      .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedExercise = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: 'Sets'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => sets = int.tryParse(value) ?? 3,
                  controller: TextEditingController(text: '3'),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: 'Reps'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => reps = int.tryParse(value) ?? 10,
                  controller: TextEditingController(text: '10'),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => weight = double.tryParse(value),
                  controller: TextEditingController(text: '0'),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: 'Rest (seconds)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => rest = int.tryParse(value) ?? 60,
                  controller: TextEditingController(text: '60'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (selectedExercise != null) {
                  setState(() {
                    selectedExercises.add(WorkoutExerciseData(
                      exerciseId: selectedExercise!.id,
                      sets: sets,
                      reps: reps,
                      weight: weight,
                      restSeconds: rest,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutExerciseData {
  final int exerciseId;
  final int sets;
  final int reps;
  final double? weight;
  final int restSeconds;

  WorkoutExerciseData({
    required this.exerciseId,
    required this.sets,
    required this.reps,
    this.weight,
    required this.restSeconds,
  });
}