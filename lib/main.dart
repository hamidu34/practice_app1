import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';

void main() {
  runApp(const MyApp());
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        ),
        home: SafeArea(child: MyHomePage()),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  // ↓ Add this.
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorite = <WordPair>[];
  void togglefav() {
    if (favorite.contains(current)) {
      favorite.remove(current);
    } else {
      favorite.add(current);
    }
    notifyListeners();
  }

  void removeFav(WordPair pair) {
    favorite.remove(pair);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedindex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedindex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedindex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedindex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedindex = value;
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

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorite.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          const Gap(10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.togglefav();
                },
                icon: Icon(icon),
                label: const Text('Like'),
              ),
              const Gap(10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    // ↓ Add this.
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: pair.asPascalCase,
        ),
      ),
    );
  }
}

class FavPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.headlineMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    var favState = context.watch<MyAppState>();
    if (favState.favorite.isEmpty) {
      return const Center(
        child: Text('No favorites yet.'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('you have ${favState.favorite.length} Favorites:'),
        ),
        const Gap(20),
        Expanded(
          child: ListView.builder(
            itemCount: favState.favorite.length,
            itemBuilder: (context, index) => Card(
              color: theme.primaryColor,
              child: ListTile(
                leading: IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: () {
                    for (var pair in favState.favorite) {
                      favState.removeFav(pair);
                    }
                  },
                ),
                title: Text('${favState.favorite[index]}', style: style),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
