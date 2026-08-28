import 'package:flutter/material.dart';

import 'person.dart';
import 'person_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Person> favorites;
  final Function(Person) onFavoriteChanged;

  const FavoritesScreen({
    super.key,
    required this.favorites,
    required this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
      ),

      body: favorites.isEmpty
          ? buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final person = favorites[index];

          return buildFavoriteCard(
            context,
            person,
          );
        },
      ),
    );
  }

  Widget buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey,
          ),

          SizedBox(height: 15),

          Text(
            'No Favorites Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Add some famous people to your favorites.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildFavoriteCard(
      BuildContext context,
      Person person,
      ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PersonDetailsScreen(
                    personId: person.id,
                  ),
            ),
          );
        },

        leading: buildPersonImage(person),

        title: Text(
          person.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          person.knownForDepartment ??
              'Unknown',
        ),

        trailing: IconButton(
          tooltip: 'Remove from favorites',
          onPressed: () {
            onFavoriteChanged(person);
          },
          icon: const Icon(
            Icons.favorite,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget buildPersonImage(Person person) {
    if (person.profilePath == null ||
        person.profilePath!.isEmpty) {
      return const CircleAvatar(
        radius: 30,
        child: Icon(Icons.person),
      );
    }

    return CircleAvatar(
      radius: 30,
      backgroundImage: NetworkImage(
        'https://image.tmdb.org/t/p/w185${person.profilePath}',
      ),
    );
  }
}