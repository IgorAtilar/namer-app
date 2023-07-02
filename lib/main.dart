import 'dart:ffi';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constrainsts) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constrainsts.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;
    var removeFavorite = appState.removeFavorite;
    final theme = Theme.of(context);

    if (favorites.isEmpty) {
      final style = theme.textTheme.displayMedium!
          .copyWith(color: theme.colorScheme.error, fontSize: 20);

      return Center(
        child: Text(
          'No favorites yet :(',
          style: style,
        ),
      );
    }

    final textStyle = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onSurface, fontSize: 20);

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
              'You have '
              '${appState.favorites.length} favorites:',
              style: textStyle),
        ),
        Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: favorites
                  .map((favorite) => Row(
                        children: [
                          FavoriteItem(
                            pair: favorite,
                            removeFavorite: removeFavorite,
                          )
                        ],
                      ))
                  .toList(),
            ))
      ],
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    var favorites = appState.favorites;
    var toggleFavorite = appState.toggleFavorite;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LikeButton(
                liked: favorites.contains(pair),
                toggleFavorite: toggleFavorite,
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LikeButton extends StatelessWidget {
  const LikeButton(
      {super.key, required this.liked, required this.toggleFavorite});

  final bool liked;
  final Function toggleFavorite;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          toggleFavorite();
        },
        child: Row(children: [
          Icon(liked ? Icons.favorite : Icons.favorite_border),
          SizedBox(width: 10),
          Text('Like')
        ]));
  }
}

class FavoriteItem extends StatelessWidget {
  const FavoriteItem({
    super.key,
    required this.pair,
    required this.removeFavorite,
  });

  final WordPair pair;
  final Function(WordPair favorite) removeFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary, fontSize: 20);

    return Card(
        color: theme.colorScheme.primary,
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Text(
                  pair.asLowerCase,
                  style: style,
                  semanticsLabel: "${pair.first} ${pair.second}",
                ),
                SizedBox(width: 4),
                IconButton(
                  onPressed: () {
                    removeFavorite(pair);
                  },
                  icon: Icon(Icons.delete),
                  color: Colors.white,
                ),
              ],
            )));
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
