class Pantun {
  String text;
  final String theme;
  final String mood;
  final String location;
  bool saved;

  Pantun({
    required this.text,
    required this.theme,
    required this.mood,
    required this.location,
    this.saved = false,
  });
}
