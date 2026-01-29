# Todo App — Spring Boot + Flutter

A simple full-stack **Todo** application: a **Spring Boot** REST API backend and a **Flutter** client (mobile, desktop, web). Users can view, add, edit, complete, and delete todos; all data is stored and served by the backend.

---

## Tech Stack

| Layer   | Technology |
|--------|------------|
| **Backend** | Spring Boot (Java) — REST API on port **8000** |
| **Frontend** | Flutter (Dart) — UI with Provider for state management |
| **API** | REST over HTTP, JSON request/response |

---

## Project Structure

```
To Do App/
├── todoapp/          ← This Flutter app (frontend)
│   ├── lib/
│   │   ├── main.dart              # App entry, Provider setup
│   │   ├── home_page.dart         # Main screen (list + dialogs)
│   │   ├── models/todo.dart       # Todo data model
│   │   ├── providers/todo_provider.dart   # State (todos, loading, errors)
│   │   └── services/
│   │       ├── todo_service.dart  # HTTP calls to backend
│   │       ├── api_host.dart      # Platform-specific API host
│   │       ├── api_host_io.dart   # Desktop/Android: 127.0.0.1 / 10.0.2.2
│   │       └── api_host_web.dart  # Web: localhost
│   ├── pubspec.yaml
│   └── README.md (this file)
│
└── <your-spring-boot-project>/   # Backend (separate repo or folder)
    └── ... (Spring Boot app exposing /api/v1/todos)
```

---

## API Contract (Backend ↔ Flutter)

The Flutter app expects the backend to expose these endpoints. Your Spring Boot app should implement them (e.g. with a `TodoController`).

| Method | Endpoint | Description |
|--------|----------|-------------|
| **GET** | `/api/v1/todos` | Return all todos (JSON array). |
| **POST** | `/api/v1/todos` | Create a todo; body: JSON todo (no `id`); return created todo with `id`. |
| **PUT** | `/api/v1/todos/{id}` | Update todo by id; body: JSON todo; return updated todo. |
| **DELETE** | `/api/v1/todos/{id}` | Delete todo by id; return 200. |

### Todo JSON shape

The app sends and accepts JSON in this shape (snake_case or camelCase both work in the Flutter model):

```json
{
  "id": 1,
  "title": "Buy milk",
  "description": "Optional description",
  "completed": false,
  "created_at": "2025-01-29T10:00:00.000Z",
  "updated_at": "2025-01-29T11:00:00.000Z"
}
```

- **id**: integer (optional in POST body; server assigns it).
- **title**: string (required).
- **description**: string or null.
- **completed**: boolean.
- **created_at**, **updated_at**: ISO 8601 date-time strings.

---

## Prerequisites

- **Java 17+** and **Maven** or **Gradle** — to run the Spring Boot backend.
- **Flutter SDK** — [Install Flutter](https://docs.flutter.dev/get-started/install).
- **Android Studio / Xcode** (optional) — for Android/iOS emulators.
- Backend running and reachable at `http://localhost:8000` (or at the host the app uses; see below).

---

## How to Run

### 1. Start the Spring Boot backend

From your Spring Boot project directory:

```bash
# Maven
./mvnw spring-boot:run

# Or Gradle
./gradlew bootRun
```

- The API should listen on **port 8000**.
- For the **Android emulator** to reach it, the server must listen on **all interfaces** (e.g. `0.0.0.0`), not only `localhost`. In `application.properties` you might have:
  ```properties
  server.address=0.0.0.0
  server.port=8000
  ```

### 2. Run the Flutter app

From this project (`todoapp/`):

```bash
# Install dependencies
flutter pub get

# Run on Windows (desktop)
flutter run -d windows

# Run on Android emulator (start emulator first: Flutter: Launch Emulator in Cursor/VS Code)
flutter run -d android

# Run in Chrome (web)
flutter run -d chrome
```

- **Windows / Web**: The app uses `127.0.0.1` or `localhost` for the API, so the backend on your PC is used.
- **Android emulator**: The app uses `10.0.2.2` (host machine) so the emulator can reach the backend on your PC. No code change needed.

If the backend is not running, the app shows a “Could not load todos” message with a **Retry** button after a short timeout.

---

## Features (Flutter app)

- **List todos** — Fetched from the backend on startup; loading and error states with Retry.
- **Add todo** — FAB (+) opens a dialog; title (required) and optional description.
- **Edit todo** — Pencil icon on a todo opens edit dialog; updates via PUT.
- **Complete todo** — Checkbox toggles `completed`; updates via PUT.
- **Delete todo** — Trash icon opens confirmation dialog; deletes via DELETE.

---

## Flutter app architecture (short)

- **UI**: `main.dart` (MaterialApp, Provider) → `home_page.dart` (list, dialogs).
- **State**: `TodoProvider` (ChangeNotifier) holds todos, loading, error; notifies UI on change.
- **Data**: `Todo` model in `models/todo.dart`; `fromJson` / `toJson` for API.
- **Network**: `TodoService` in `services/todo_service.dart` does HTTP; `api_host_*.dart` picks the right host per platform.

---

## License

This project is for learning/demo use. Adjust as needed for your own repo.
