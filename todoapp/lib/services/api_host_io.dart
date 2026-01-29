/// # API Host - Mobile & Desktop (api_host_io.dart)
///
/// Used when the app runs on **Android, iOS, Windows, Linux, macOS** (not web).
/// [dart:io] is available on these platforms, so we can use [Platform.isAndroid].
///
/// ## Why different hosts?
/// - **127.0.0.1** (desktop/Windows): The app and the backend run on the same machine,
///   so "this machine" is 127.0.0.1 (or localhost).
/// - **10.0.2.2** (Android emulator): Inside the emulator, "localhost" is the emulator
///   itself, not your PC. 10.0.2.2 is a special address that means "the host machine"
///   from inside the Android emulator, so the app can reach your backend on the PC.

import 'dart:io';

/// Host for the API. Use 10.0.2.2 on Android emulator to reach host machine.
String get apiHost => Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
