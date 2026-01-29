/// # Todo Provider (providers/todo_provider.dart)
///
/// **State management** for the todo list. This class:
/// - Holds the list of todos, loading flag, and error message.
/// - Calls [TodoService] to talk to the API (fetch, add, update, delete).
/// - Uses [ChangeNotifier] so when we call [notifyListeners()], every [Consumer]
///   in the UI (e.g. HomePage) rebuilds and shows the new data.
///
/// ## Why use a Provider?
/// Without it, we'd have to pass the list and callbacks through every widget.
/// With Provider, any screen can read/update todos via [context.read<TodoProvider>()].

import 'package:flutter/material.dart';
import 'package:todoapp/models/todo.dart';
import 'package:todoapp/services/todo_service.dart';

/// [ChangeNotifier] is a mixin that lets us call [notifyListeners()] to tell the UI to refresh.
class TodoProvider with ChangeNotifier {
  final TodoService _todoService = TodoService();
  List<Todo> _todos = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// Public getters so the UI can read state without modifying it.
  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches all todos from the API. Sets [isLoading] and [errorMessage] so the UI
  /// can show spinner or error. [notifyListeners()] triggers a rebuild of [Consumer] widgets.
  Future<void> fetchTodos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _todos = await _todoService.getTodos();
      _errorMessage = null;
    } catch (e, stackTrace) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint("Error fetching todos: $e");
      debugPrint("Stack trace: $stackTrace");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new todo on the server and adds the returned todo (with id) to the list.
  Future<void> addTodo(Todo todo) async {
    try {
      final newTodo = await _todoService.createTodo(todo);
      _todos.add(newTodo);
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint("Error adding todo: $e");
      debugPrint("Stack trace: $stackTrace");
    }
  }

  /// Updates a todo on the server and replaces the item in the list.
  Future<void> updateTodo(Todo todo) async {
    try {
      final updatedTodo = await _todoService.updateTodo(todo);
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = updatedTodo;
        notifyListeners();
      }
    } catch (e, stackTrace) {
      debugPrint("Error updating todo: $e");
      debugPrint("Stack trace: $stackTrace");
    }
  }

  /// Deletes a todo on the server and removes it from the list.
  Future<void> deleteTodo(int id) async {
    try {
      await _todoService.deleteTodo(id);
      _todos.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint("Error deleting todo: $e");
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
