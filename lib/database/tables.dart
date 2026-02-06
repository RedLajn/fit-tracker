import 'package:drift/drift.dart';

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  TextColumn get muscleGroup => text().withLength(min: 1, max: 50)();
  TextColumn get equipment => text().withLength(min: 1, max: 50)();
  TextColumn get imageUrl => text().nullable()();
}

class WorkoutPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class WorkoutExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutPlanId => integer().references(WorkoutPlans, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId => integer().references(Exercises, #id, onDelete: KeyAction.cascade)();
  IntColumn get sets => integer()();
  IntColumn get reps => integer()();
  RealColumn get weight => real().nullable()();
  IntColumn get restSeconds => integer()();
  IntColumn get orderIndex => integer()();
}

class WorkoutSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutPlanId => integer().references(WorkoutPlans, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
}

class SessionExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId => integer().references(Exercises, #id, onDelete: KeyAction.cascade)();
  IntColumn get setsCompleted => integer()();
  TextColumn get repsActual => text()();
  TextColumn get weightActual => text()();
}

class UserSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get weightUnit => text().withDefault(const Constant('kg'))();
  RealColumn get height => real().nullable()();
  RealColumn get weight => real().nullable()();
  IntColumn get age => integer().nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get theme => text().withDefault(const Constant('system'))();
}