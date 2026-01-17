import 'package:lumora/layouts/models/meal_plan.dart';

final List<MealPlan> mealPlans = [
  MealPlan(
    id: "meal_week1",
    title: "Week 1 – Balanced Diet",
    days: [
      MealDay(day: "Monday", meals: "High protein"),
      MealDay(day: "Tuesday", meals: "Low carb"),
      MealDay(day: "Wednesday", meals: "Balanced"),
      MealDay(day: "Thursday", meals: "Vegetarian"),
      MealDay(day: "Friday", meals: "High carb"),
      MealDay(day: "Saturday", meals: "Protein rich"),
      MealDay(day: "Sunday", meals: "Cheat meal"),
    ],
  ),
];
