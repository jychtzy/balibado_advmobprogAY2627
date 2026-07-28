import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings.dart';

// Entry point of the application.
void main() {
  runApp(
    // Makes ThemeModel available to the entire application.
    ChangeNotifierProvider(
      create: (context) => ThemeModel(),
      child: const MyApp(),
    ),
  );
}

// Root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Gets the current theme from ThemeModel.
    final themeModel = Provider.of<ThemeModel>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ephemeral & App State Example',

      // Changes the app theme based on the Provider value.
      theme: themeModel.isDark ? ThemeData.dark() : ThemeData.light(),

      home: const MyHomePage(),
    );
  }
}

// Home screen that demonstrates Ephemeral State.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// State class for MyHomePage.
class _MyHomePageState extends State<MyHomePage> {

  // Local counter used as an Ephemeral State.
  // It only belongs to this screen.
  int _counter = 0;

  // Increases the counter by one.
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ephemeral vs App State'),

        actions: [
          // Opens the Settings screen.
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {

              // Wait until the user returns from Settings.
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );

              // Gets the current ThemeModel.
              final themeModel =
                  Provider.of<ThemeModel>(context, listen: false);

              // Reset the counter if the theme was changed.
              if (themeModel.themeChanged) {
                setState(() {
                  _counter = 0;
                });

                // Clears the themeChanged flag.
                themeModel.resetThemeChanged();
              }
            },
          ),
        ],
      ),

      // Displays the counter in the center of the screen.
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You have pushed the button this many times:',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 10),

            // Shows the current counter value.
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),

      // Button that increases the counter.
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}