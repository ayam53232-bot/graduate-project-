import 'package:flutter/material.dart';

import 'person.dart';
import 'api_service.dart';
import 'chat_screen.dart';
import 'favorites_screen.dart';
import 'person_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();

  List<Person> persons = [];
  List<Person> favorites = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    getPopularPersons();
  }

  Future<void> getPopularPersons() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await apiService.getPopularPersons();

      if (!mounted) return;

      setState(() {
        persons = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load persons.';
      });
    }
  }

  void toggleFavorite(Person person) {
    setState(() {
      final isAlreadyFavorite = favorites.any(
            (item) => item.id == person.id,
      );

      if (isAlreadyFavorite) {
        favorites.removeWhere(
              (item) => item.id == person.id,
        );
      } else {
        favorites.add(person);
      }
    });
  }

  bool isFavorite(Person person) {
    return favorites.any(
          (item) => item.id == person.id,
    );
  }

  void openFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesScreen(
          favorites: favorites,
          onFavoriteChanged: toggleFavorite,
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatScreen(),
      ),
    );
  }

  void openPersonDetails(Person person) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonDetailsScreen(
          personId: person.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Famous People',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'AI Assistant',
            onPressed: openChat,
            icon: const Icon(
              Icons.smart_toy_outlined,
            ),
          ),

          IconButton(
            tooltip: 'Favorites',
            onPressed: openFavorites,
            icon: const Icon(
              Icons.favorite,
              color: Colors.red,
            ),
          ),
        ],
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 70,
                color: Colors.red,
              ),

              const SizedBox(height: 15),

              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 15),

              ElevatedButton.icon(
                onPressed: getPopularPersons,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (persons.isEmpty) {
      return RefreshIndicator(
        onRefresh: getPopularPersons,
        child: ListView(
          children: const [
            SizedBox(height: 250),
            Center(
              child: Text(
                'No persons found.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: getPopularPersons,
      child: GridView.builder(
        padding: const EdgeInsets.all(12),

        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.62,
        ),

        itemCount: persons.length,

        itemBuilder: (context, index) {
          final person = persons[index];

          return buildPersonCard(person);
        },
      ),
    );
  }

  Widget buildPersonCard(Person person) {
    final favorite = isFavorite(person);

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          openPersonDetails(person);
        },

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: buildPersonImage(person),
                  ),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 3,
                      child: IconButton(
                        onPressed: () {
                          toggleFavorite(person);
                        },
                        icon: Icon(
                          favorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: favorite
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                10,
                10,
                10,
                4,
              ),
              child: Text(
                person.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                10,
                0,
                10,
                10,
              ),
              child: Text(
                person.knownForDepartment ?? 'Unknown',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPersonImage(Person person) {
    if (person.profilePath == null ||
        person.profilePath!.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(
            Icons.person,
            size: 80,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Image.network(
      'https://image.tmdb.org/t/p/w500${person.profilePath}',

      fit: BoxFit.cover,

      errorBuilder: (
          context,
          error,
          stackTrace,
          ) {
        return Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(
              Icons.broken_image,
              size: 60,
              color: Colors.grey,
            ),
          ),
        );
      },

      loadingBuilder: (
          context,
          child,
          loadingProgress,
          ) {
        if (loadingProgress == null) {
          return child;
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}