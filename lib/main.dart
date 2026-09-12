import 'package:flutter/material.dart';

import 'screens/todo_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Colors.teal;

    return MaterialApp(
      title: 'Tareas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: ColorScheme.fromSeed(seedColor: seed).surface,
        chipTheme: const ChipThemeData(showCheckmark: false),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        chipTheme: const ChipThemeData(showCheckmark: false),
      ),
      themeMode: ThemeMode.system,
      home: const TodoScreen(),
    );
  }
}
