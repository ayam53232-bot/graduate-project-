import 'package:flutter/material.dart';

import 'person.dart';
import 'person_image.dart';
import 'api_service.dart';
import 'image_viewer_screen.dart';

class PersonDetailsScreen extends StatefulWidget {
  final int personId;

  const PersonDetailsScreen({
    super.key,
    required this.personId,
  });

  @override
  State<PersonDetailsScreen> createState() =>
      _PersonDetailsScreenState();
}

class _PersonDetailsScreenState
    extends State<PersonDetailsScreen> {
  final ApiService apiService = ApiService();

  Person? person;
  List<PersonImage> images = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadPersonData();
  }

  Future<void> loadPersonData() async {
    try {
      final results = await Future.wait([
        apiService.getPersonDetails(widget.personId),
        apiService.getPersonImages(widget.personId),
      ]);

      if (!mounted) return;

      setState(() {
        person = results[0] as Person;
        images = results[1] as List<PersonImage>;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
        'Failed to load person details.';
      });
    }
  }

  void openImage(String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewerScreen(
          imageUrl:
          'https://image.tmdb.org/t/p/original$filePath',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          person?.name ?? 'Person Details',
        ),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 70,
              color: Colors.red,
            ),
            const SizedBox(height: 15),
            Text(errorMessage!),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: loadPersonData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (person == null) {
      return const Center(
        child: Text('No data found.'),
      );
    }

    final currentPerson = person!;

    return RefreshIndicator(
      onRefresh: loadPersonData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildProfileImage(currentPerson),

          const SizedBox(height: 20),

          Text(
            currentPerson.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          buildInfoRow(
            'Department',
            currentPerson.knownForDepartment ??
                'Unknown',
          ),

          buildInfoRow(
            'Birthday',
            currentPerson.birthday ?? 'Unknown',
          ),

          buildInfoRow(
            'Place of Birth',
            currentPerson.placeOfBirth ??
                'Unknown',
          ),

          buildInfoRow(
            'Popularity',
            currentPerson.popularity
                .toStringAsFixed(2),
          ),

          const SizedBox(height: 20),

          const Text(
            'Biography',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            currentPerson.biography?.isNotEmpty ==
                true
                ? currentPerson.biography!
                : 'No biography available.',
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'Photos',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          buildPhotos(),
        ],
      ),
    );
  }

  Widget buildProfileImage(Person person) {
    if (person.profilePath == null ||
        person.profilePath!.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.person,
          size: 120,
          color: Colors.grey,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        'https://image.tmdb.org/t/p/w500${person.profilePath}',
        height: 320,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildInfoRow(
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$title:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget buildPhotos() {
    if (images.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'No photos available.',
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics:
      const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final image = images[index];

        if (image.filePath == null ||
            image.filePath!.isEmpty) {
          return Container(
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.image,
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            openImage(image.filePath!);
          },
          child: ClipRRect(
            borderRadius:
            BorderRadius.circular(10),
            child: Image.network(
              'https://image.tmdb.org/t/p/w500${image.filePath}',
              fit: BoxFit.cover,
              errorBuilder: (
                  context,
                  error,
                  stackTrace,
                  ) {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.broken_image,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}