class Person {
  final int id;
  final String name;
  final String? profilePath;
  final double popularity;
  final String? knownForDepartment;
  final String? biography;
  final String? birthday;
  final String? placeOfBirth;

  Person({
    required this.id,
    required this.name,
    this.profilePath,
    required this.popularity,
    this.knownForDepartment,
    this.biography,
    this.birthday,
    this.placeOfBirth,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      profilePath: json['profile_path'],
      popularity: (json['popularity'] ?? 0).toDouble(),
      knownForDepartment: json['known_for_department'],
      biography: json['biography'],
      birthday: json['birthday'],
      placeOfBirth: json['place_of_birth'],
    );
  }
}