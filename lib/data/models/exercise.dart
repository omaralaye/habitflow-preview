class Exercise {
  final String name;
  final String videoUrl;
  final String imageUrl;
  final String semanticLabel;
  final int sets;
  final int reps;
  final int restTime;
  final String instructions;

  const Exercise({
    required this.name,
    required this.videoUrl,
    required this.imageUrl,
    required this.semanticLabel,
    required this.sets,
    required this.reps,
    required this.restTime,
    required this.instructions,
  });
}
