import 'package:drift/drift.dart';
import 'database.dart';

Future<void> seedDatabase(AppDatabase db) async {
  final exerciseCount = await db.exercises.count().getSingle();

  if (exerciseCount > 0) {
    return;
  }

  await db.batch((batch) {
    batch.insertAll(db.exercises, [
      ExercisesCompanion.insert(
        name: 'Bench Press',
        description: const Value('Lie on bench, lower bar to chest, press up'),
        muscleGroup: 'Chest',
        equipment: 'Barbell',
        imageUrl: const Value(null),
      ),
      ExercisesCompanion.insert(
        name: 'Squat',
        description: const Value('Stand with bar on shoulders, squat down, stand up'),
        muscleGroup: 'Legs',
        equipment: 'Barbell',
        imageUrl: const Value(null),
      ),
      ExercisesCompanion.insert(
        name: 'Deadlift',
        description: const Value('Bend down, grip bar, stand up straight'),
        muscleGroup: 'Back',
        equipment: 'Barbell',
        imageUrl: const Value(null),
      ),
      ExercisesCompanion.insert(
        name: 'Shoulder Press',
        description: const Value('Press dumbbells overhead from shoulder height'),
        muscleGroup: 'Shoulders',
        equipment: 'Dumbbell',
        imageUrl: const Value(null),
      ),
      ExercisesCompanion.insert(
        name: 'Pull-ups',
        description: const Value('Hang from bar, pull body up until chin over bar'),
        muscleGroup: 'Back',
        equipment: 'Bodyweight',
        imageUrl: const Value(null),
      ),
      ExercisesCompanion.insert(
        name: 'Bicep Curls',
        description: const Value('Curl dumbbells from hip to shoulder'),
        muscleGroup: 'Arms',
        equipment: 'Dumbbell',
        imageUrl: const Value(null),
      ),
      ExercisesCompanion.insert(
        name: 'Tricep Dips',
        description: const Value('Lower body between parallel bars, push back up'),
        muscleGroup: 'Arms',
        equipment: 'Bodyweight',
        imageUrl: const Value(null),
      ),
      ExercisesCompanion.insert(
        name: 'Lunges',
        description: const Value('Step forward, lower back knee, return to standing'),
        muscleGroup: 'Legs',
        equipment: 'Bodyweight',
        imageUrl: const Value(null),
      ),
      ExercisesCompanion.insert(
        name: 'Plank',
        description: const Value('Hold body straight in push-up position on forearms'),
        muscleGroup: 'Core',
        equipment: 'Bodyweight',
        imageUrl: const Value(null),
      ),
      ExercisesCompanion.insert(
        name: 'Leg Press',
        description: const Value('Push platform away with legs from seated position'),
        muscleGroup: 'Legs',
        equipment: 'Machine',
        imageUrl: const Value(null),
      ),
    ]);
  });
}