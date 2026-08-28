import 'dart:convert';
import 'package:http/http.dart' as http;

import 'person.dart';
import 'person_image.dart';

class ApiService {
  static const String baseUrl =
      'https://api.themoviedb.org/3';

  static const String apiKey =
      '2dfe23358236069710a379edd4c65a6b';

  Future<List<Person>> getPopularPersons() async {
    final url = Uri.parse(
      '$baseUrl/person/popular?api_key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List results = data['results'] ?? [];

      return results
          .map((person) => Person.fromJson(person))
          .toList();
    }

    throw Exception('Failed to load popular persons');
  }

  Future<Person> getPersonDetails(int id) async {
    final url = Uri.parse(
      '$baseUrl/person/$id?api_key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return Person.fromJson(data);
    }

    throw Exception('Failed to load person details');
  }

  Future<List<PersonImage>> getPersonImages(
      int id,
      ) async {
    final url = Uri.parse(
      '$baseUrl/person/$id/images?api_key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List profiles = data['profiles'] ?? [];

      return profiles
          .map(
            (image) => PersonImage.fromJson(image),
      )
          .toList();
    }

    throw Exception('Failed to load person images');
  }
}