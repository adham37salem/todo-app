/// # Todo Model (models/todo.dart)
///
/// This file defines the **data shape** of a single todo item. It does not depend
/// on Flutter or the backend—it's plain Dart. Used everywhere we need to pass or
/// display a todo (home_page, provider, service).
///
/// ## Concepts:
/// - **Model**: A class that holds data (id, title, description, completed, dates).
/// - **fromJson**: Converts JSON from the API into a [Todo] object (parsing).
/// - **toJson**: Converts a [Todo] into a Map for sending to the API (serialization).
/// - We support both **snake_case** (created_at) and **camelCase** (createdAt) from the backend.

/// Helper: safely parse an id from JSON. Backend may send int, double, or String.
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

/// A single todo item. [id] is null when creating a new todo (server assigns it).
/// [description] and [updatedAt] are optional.
class Todo {
  final int? id;
  final String title;
  final String? description;
  final bool completed;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Todo({
    this.id,
    required this.title,
    this.description,
    required this.completed,
    required this.createdAt,
    this.updatedAt,
  });

  /// Builds a [Todo] from a JSON map (e.g. from the API).
  /// - Uses [safeString] / [safeStringOrNull] so null from API doesn't crash the app.
  /// - [toCamel] converts snake_case keys to camelCase so we support both (e.g. created_at → createdAt).
  factory Todo.fromJson(Map<String, dynamic> json) {
    String safeString(dynamic v) => (v == null) ? '' : v.toString();
    String? safeStringOrNull(dynamic v) => (v == null) ? null : v.toString();
    String toCamel(String s) {
      final parts = s.split('_');
      if (parts.isEmpty) return s;
      return parts.first.toLowerCase() +
          parts
              .skip(1)
              .map(
                (e) => e.isEmpty
                    ? e
                    : '${e[0].toUpperCase()}${e.substring(1).toLowerCase()}',
              )
              .join();
    }
    dynamic get(String k) => json[k] ?? json[toCamel(k)];

    final createdAtRaw = get('created_at');
    final updatedAtRaw = get('updated_at');
    return Todo(
      id: _parseInt(get('id')),
      title: safeString(get('title')),
      description: safeStringOrNull(get('description')),
      completed: get('completed') == true,
      createdAt: createdAtRaw != null
          ? DateTime.tryParse(createdAtRaw.toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: updatedAtRaw != null
          ? DateTime.tryParse(updatedAtRaw.toString())
          : null,
    );
  }

  /// Converts this [Todo] to a JSON map for sending to the API (POST/PUT body).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
