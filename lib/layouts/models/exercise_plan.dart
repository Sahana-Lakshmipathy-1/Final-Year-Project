class ExercisePlan {
  final String id;
  final String title;
  final List<ExerciseDay> days;

  ExercisePlan({
    required this.id,
    required this.title,
    required this.days,
  });
}

class ExerciseDay {
  final String day;
  String workout;

  ExerciseDay({
    required this.day,
    required this.workout,
  });
}
