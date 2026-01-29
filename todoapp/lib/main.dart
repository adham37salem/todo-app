/// # Main Entry Point (main.dart)
///
/// This is the **entry point** of the Flutter app. When you run the app,
/// Dart calls the `main()` function first. Everything starts here.
///
/// ## What this file does:
/// 1. Wraps the app with [ChangeNotifierProvider] so all screens can access
///    the todo list state (via [TodoProvider]).
/// 2. Defines [MyApp], the root widget that sets up [MaterialApp] (theme, title, home screen).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todoapp/home_page.dart';
import 'package:todoapp/providers/todo_provider.dart';

/// App entry point. [runApp] tells Flutter what to display on screen.
/// We wrap [MyApp] with [ChangeNotifierProvider] so [TodoProvider] is available
/// everywhere in the widget tree (see home_page.dart and todo_provider.dart).
void main() {
  runApp(
    ChangeNotifierProvider(create: (context) => TodoProvider(), child: MyApp()),
  );
}

/// Root widget of the app. [StatelessWidget] = no internal state that changes over time.
/// [MaterialApp] is the standard Flutter app shell (theme, navigation, title).
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}
