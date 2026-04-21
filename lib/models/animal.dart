enum AnimalCategory { all, dog, cat, other }

class Animal {
  const Animal({
    required this.id,
    required this.name,
    required this.category,
    required this.gender,
    required this.ageText,
    required this.location,
    required this.imagePath,
  });

  final String id;
  final String name;
  final AnimalCategory category;
  final String gender;
  final String ageText;
  final String location;
  final String imagePath;
}
