import 'package:flutter/material.dart';

class ExerciseIcons {
  static IconData getMuscleGroupIcon(String muscleGroup) {
    switch (muscleGroup.toLowerCase()) {
      case 'chest':
        return Icons.fitness_center;
      case 'back':
        return Icons.accessibility_new;
      case 'legs':
        return Icons.directions_run;
      case 'shoulders':
        return Icons.airline_seat_recline_normal;
      case 'arms':
        return Icons.sports_martial_arts;
      case 'core':
        return Icons.self_improvement;
      default:
        return Icons.sports_gymnastics;
    }
  }

  static Color getMuscleGroupColor(String muscleGroup) {
    switch (muscleGroup.toLowerCase()) {
      case 'chest':
        return Colors.red;
      case 'back':
        return Colors.blue;
      case 'legs':
        return Colors.green;
      case 'shoulders':
        return Colors.orange;
      case 'arms':
        return Colors.purple;
      case 'core':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  static IconData getEquipmentIcon(String equipment) {
    switch (equipment.toLowerCase()) {
      case 'barbell':
        return Icons.fitness_center;
      case 'dumbbell':
        return Icons.sports_gymnastics;
      case 'machine':
        return Icons.precision_manufacturing;
      case 'bodyweight':
        return Icons.accessibility;
      case 'cable':
        return Icons.cable;
      case 'kettlebell':
        return Icons.sports_handball;
      default:
        return Icons.sports;
    }
  }
}