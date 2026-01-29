/// # Todo Service (services/todo_service.dart)
///
/// Handles **all HTTP requests** to the backend API. The app never talks to the
/// server directly—it goes through [TodoProvider], which calls this service.
///
/// ## What it does:
/// - [getTodos]: GET /api/v1/todos → list of todos
/// - [createTodo]: POST /api/v1/todos → new todo (with id)
/// - [updateTodo]: PUT /api/v1/todos/:id → updated todo
/// - [deleteTodo]: DELETE /api/v1/todos/:id
///
/// ## Details:
/// - [baseUrl] uses [apiHost] so it works on Windows (127.0.0.1) and Android emulator (10.0.2.2).
/// - Every request has a 5-second timeout so the app doesn't hang if the server is down.
/// - We parse JSON with [Todo.fromJson] and send JSON with [todo.toJson].

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:todoapp/models/todo.dart';
import 'package:todoapp/services/api_host.dart';

class TodoService {
  /// Base URL for the API. [apiHost] is 127.0.0.1 on desktop, 10.0.2.2 on Android emulator (see api_host_io.dart).
  String get baseUrl => 'http://$apiHost:8000/api/v1/todos';
  static const _timeout = Duration(seconds: 5);

  /// GET all todos. Returns a list of [Todo]. Throws on non-200 or timeout.
  Future<List<Todo>> getTodos() async {
    final response = await http
        .get(Uri.parse(baseUrl))
        .timeout(
          _timeout,
          onTimeout: () {
            throw Exception(
              'Connection timed out. Is the backend running on port 8000?',
            );
          },
        );
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((todo) => Todo.fromJson(todo)).toList();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  /// POST a new todo. Sends [todo.toJson()], returns the created todo (with id) from the response.
  Future<Todo> createTodo(Todo todo) async {
    final response = await http
        .post(
          Uri.parse(baseUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(todo.toJson()),
        )
        .timeout(_timeout);
    if (response.statusCode == 200) {
      return Todo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create todo');
    }
  }

  /// PUT to update an existing todo. URL includes [todo.id].
  Future<Todo> updateTodo(Todo todo) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/${todo.id}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(todo.toJson()),
        )
        .timeout(_timeout);
    if (response.statusCode == 200) {
      return Todo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update todo');
    }
  }

  /// DELETE a todo by id.
  Future<void> deleteTodo(int id) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/$id'))
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete todo');
    } else {
      return;
    }
  }
}
