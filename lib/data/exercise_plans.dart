import 'package:lumora/layouts/models/exercise_plan.dart';

final List<ExercisePlan> exercisePlans = [
  ExercisePlan(
    id: "ex_week1",
    title: "Week 1 – Beginner Exercise",
    days: [
      ExerciseDay(day: "Monday", workout: "Full Body"),
      ExerciseDay(day: "Tuesday", workout: "Cardio"),
      ExerciseDay(day: "Wednesday", workout: "Upper Body"),
      ExerciseDay(day: "Thursday", workout: "Yoga"),
      ExerciseDay(day: "Friday", workout: "Lower Body"),
      ExerciseDay(day: "Saturday", workout: "HIIT"),
      ExerciseDay(day: "Sunday", workout: "Rest"),
    ],
  ),
];
