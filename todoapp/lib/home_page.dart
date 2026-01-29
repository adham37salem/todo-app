/// # Home Page (home_page.dart)
///
/// The **main screen** of the Todo app. It shows the list of todos and lets the user
/// add, edit, complete, and delete them.
///
/// ## Key Flutter concepts used here:
/// - [StatefulWidget]: This screen has state (it reacts when the todo list changes).
/// - [Consumer]/[Provider]: Reads [TodoProvider] so the UI updates when todos change.
/// - [Scaffold]: Standard page layout (app bar, body, floating action button).
/// - [ListView.builder]: Builds list items on demand (efficient for long lists).
/// - [showDialog]: Pops up a dialog for Add/Edit/Delete.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todoapp/models/todo.dart';
import 'package:todoapp/providers/todo_provider.dart';

/// A [StatefulWidget] has two classes: the Widget and its State.
/// The Widget is immutable; the State holds data and rebuilds the UI when it changes.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  /// Called once when this screen is first created.
  /// We load todos from the API here. [Future.microtask] runs after the first frame
  /// so we don't call [context.read] during build. [mounted] check avoids calling
  /// after the widget was removed from the tree.
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) {
        return;
      }
      context.read<TodoProvider>().fetchTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo App')),

      /// [Consumer<TodoProvider>] rebuilds only this part when TodoProvider calls notifyListeners().
      /// So when todos load or change, the list updates automatically.
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          // --- Loading: show spinner when fetching and list is empty ---
          if (todoProvider.isLoading && todoProvider.todos.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }
          // --- Error: show message and Retry when fetch failed ---
          if (todoProvider.errorMessage != null && todoProvider.todos.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Could not load todos',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      todoProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => todoProvider.fetchTodos(),
                      icon: Icon(Icons.refresh),
                      label: Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          // --- Empty list (no error): prompt user to add first todo ---
          if (todoProvider.todos.isEmpty) {
            return Center(
              child: Text(
                'No todos yet. Tap + to add one.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          // --- List of todos: one [Card] + [ListTile] per todo ---
          return ListView.builder(
            itemCount: todoProvider.todos.length,
            itemBuilder: (context, index) {
              final todo = todoProvider.todos[index];
              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),

                  /// Checkbox toggles completed. We create a new Todo with updated [completed] and call updateTodo.
                  leading: Checkbox(
                    value: todo.completed,
                    onChanged: (bool? value) {
                      if (value != null) {
                        todoProvider.updateTodo(
                          Todo(
                            id: todo.id,
                            title: todo.title,
                            description: todo.description,
                            completed: value,
                            createdAt: todo.createdAt,
                            updatedAt: DateTime.now(),
                          ),
                        );
                      }
                    },
                  ),

                  /// Title with line-through when completed.
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: todo.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),

                  /// Optional description; only shown if not null/empty.
                  subtitle:
                      todo.description != null && todo.description!.isNotEmpty
                      ? Text(
                          todo.description!,
                          style: TextStyle(
                            decoration: todo.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        )
                      : null,

                  /// Edit and Delete buttons. [mainAxisSize: MainAxisSize.min] so the Row doesn't take full width (fixes ListTile layout).
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _showEditDialog(context, todo),
                        icon: Icon(Icons.edit, color: Colors.blue),
                      ),
                      IconButton(
                        onPressed: () => _showDeleteDialog(context, todo),
                        icon: Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      /// Floating action button: opens Add dialog.
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  /// Shows a dialog to add a new todo. We use local variables [title] and [description]
  /// updated by [TextField.onChanged]. On Add we create a [Todo] (no id yet) and call [TodoProvider.addTodo].
  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        String description = '';
        return AlertDialog(
          title: Text('Add New Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (value) => title = value,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (title.isNotEmpty) {
                  context.read<TodoProvider>().addTodo(
                    Todo(
                      title: title,
                      description: description,
                      completed: false,
                      createdAt: DateTime.now(),
                    ),
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Todo added successfully')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Shows a dialog to edit an existing todo. Pre-fills fields with [todo] data.
  /// [TextEditingController] sets initial text; [onChanged] updates local [title]/[description].
  /// On Save we call [TodoProvider.updateTodo] with the same id and updated fields.
  void _showEditDialog(BuildContext context, Todo todo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = todo.title;
        String description = todo.description ?? '';
        return AlertDialog(
          title: Text('Edit Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(hintText: 'Title'),
                onChanged: (value) => title = value,
                controller: TextEditingController(text: title),
              ),
              TextField(
                decoration: InputDecoration(hintText: 'Description'),
                onChanged: (value) => description = value,
                controller: TextEditingController(text: description),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                if (title.isNotEmpty) {
                  context.read<TodoProvider>().updateTodo(
                    Todo(
                      id: todo.id,
                      title: title,
                      description: description,
                      completed: todo.completed,
                      createdAt: todo.createdAt,
                      updatedAt: DateTime.now(),
                    ),
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Todo updated successfully')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Shows a confirmation dialog before deleting. On Delete we call [TodoProvider.deleteTodo] with [todo.id].
  void _showDeleteDialog(BuildContext context, Todo todo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Todo'),
          content: Text('Are you sure you want to delete this todo?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                final id = todo.id;
                if (id != null) {
                  context.read<TodoProvider>().deleteTodo(id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Todo deleted successfully')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
