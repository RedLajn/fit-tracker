import 'dart:async';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database.dart';
import '../main.dart';
import '../utils/exercise_icons.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final WorkoutPlan plan;
  final List<WorkoutExercise> exercises;

  const WorkoutSessionScreen({
    super.key,
    required this.plan,
    required this.exercises,
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  int currentExerciseIndex = 0;
  int currentSet = 1;
  bool isResting = false;
  int remainingSeconds = 0;
  Timer? timer;
  int? sessionId;
  Map<int, Exercise> exerciseDetails = {};
  List<Map<String, dynamic>> completedSets = [];

  @override
  void initState() {
    super.initState();
    startSession();
    loadExerciseDetails();
  }

  Future<void> startSession() async {
    sessionId = await database.into(database.workoutSessions).insert(
      WorkoutSessionsCompanion.insert(
        workoutPlanId: widget.plan.id,
        startedAt: DateTime.now(),
      ),
    );
  }

  Future<void> loadExerciseDetails() async {
    for (var exercise in widget.exercises) {
      final detail = await (database.select(database.exercises)
        ..where((tbl) => tbl.id.equals(exercise.exerciseId)))
          .getSingle();
      exerciseDetails[exercise.exerciseId] = detail;
    }
    setState(() {});
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startRestTimer() {
    final currentExercise = widget.exercises[currentExerciseIndex];
    setState(() {
      isResting = true;
      remainingSeconds = currentExercise.restSeconds;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          isResting = false;
        });
      }
    });
  }

  void completeSet() {
    final currentExercise = widget.exercises[currentExerciseIndex];

    completedSets.add({
      'exercise_id': currentExercise.exerciseId,
      'set': currentSet,
      'reps': currentExercise.reps,
      'weight': currentExercise.weight ?? 0,
    });

    if (currentSet < currentExercise.sets) {
      setState(() {
        currentSet++;
      });
      startRestTimer();
    } else {
      if (currentExerciseIndex < widget.exercises.length - 1) {
        setState(() {
          currentExerciseIndex++;
          currentSet = 1;
        });
      } else {
        finishWorkout();
      }
    }
  }

  Future<void> finishWorkout() async {
    if (sessionId == null) return;

    final session = await (database.select(database.workoutSessions)
      ..where((tbl) => tbl.id.equals(sessionId!)))
        .getSingle();

    await (database.update(database.workoutSessions)
      ..where((tbl) => tbl.id.equals(sessionId!)))
        .write(
      WorkoutSessionsCompanion(
        completedAt: drift.Value(DateTime.now()),
      ),
    );

    for (var exerciseId in completedSets.map((s) => s['exercise_id']).toSet()) {
      final sets = completedSets.where((s) => s['exercise_id'] == exerciseId).toList();
      await database.into(database.sessionExercises).insert(
        SessionExercisesCompanion.insert(
          sessionId: sessionId!,
          exerciseId: exerciseId,
          setsCompleted: sets.length,
          repsActual: sets.map((s) => s['reps'].toString()).join(','),
          weightActual: sets.map((s) => s['weight'].toString()).join(','),
        ),
      );
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Workout Complete!'),
          content: const Text('Great job! Your workout has been saved.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (exerciseDetails.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentExercise = widget.exercises[currentExerciseIndex];
    final exerciseDetail = exerciseDetails[currentExercise.exerciseId];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.plan.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cancel Workout?'),
                  content: const Text('Your progress will not be saved.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Continue'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel Workout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (currentExerciseIndex + (currentSet / currentExercise.sets)) /
                widget.exercises.length,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    ExerciseIcons.getMuscleGroupIcon(exerciseDetail?.muscleGroup ?? ''),
                    size: 64,
                    color: ExerciseIcons.getMuscleGroupColor(exerciseDetail?.muscleGroup ?? ''),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    exerciseDetail?.name ?? 'Loading...',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Exercise ${currentExerciseIndex + 1} of ${widget.exercises.length}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${exerciseDetail?.muscleGroup} • ${exerciseDetail?.equipment}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 48),
                  if (isResting)
                    Column(
                      children: [
                        const Text(
                          'Rest Time',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          ),
                          child: Center(
                            child: Text(
                              '$remainingSeconds',
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Text(
                          'Set $currentSet of ${currentExercise.sets}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                const Text('Reps', style: TextStyle(fontSize: 18)),
                                const SizedBox(height: 8),
                                Text(
                                  '${currentExercise.reps}',
                                  style: const TextStyle(
                                      fontSize: 48, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text('Weight', style: TextStyle(fontSize: 18)),
                                const SizedBox(height: 8),
                                Text(
                                  '${currentExercise.weight ?? 0} kg',
                                  style: const TextStyle(
                                      fontSize: 48, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                        ElevatedButton(
                          onPressed: completeSet,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(200, 60),
                            textStyle: const TextStyle(fontSize: 20),
                          ),
                          child: const Text('Complete Set'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}