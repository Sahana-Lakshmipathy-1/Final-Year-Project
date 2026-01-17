class MealPlan {
  final String id;
  final String title;
  final List<MealDay> days;

  MealPlan({
    required this.id,
    required this.title,
    required this.days,
  });
}

class MealDay {
  final String day;
  String meals;

  MealDay({
    required this.day,
    required this.meals,
  });
}
