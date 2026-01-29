/// # API Host (services/api_host.dart)
///
/// This file **does not define** the host itself. It *exports* one of two files:
/// - On **mobile/desktop** (Android, iOS, Windows, etc.): we use [api_host_io.dart],
///   which uses [dart:io] [Platform] to pick 10.0.2.2 on Android and 127.0.0.1 elsewhere.
/// - On **web**: we use [api_host_web.dart], which returns 'localhost' (no dart:io on web).
///
/// The app imports this file and gets a single [apiHost] getter. Flutter compiles
/// with the right implementation for the platform you're building for.

// Export platform-specific implementation.
// On Android emulator, 10.0.2.2 is the host machine's loopback.
export 'api_host_io.dart' if (dart.library.html) 'api_host_web.dart';
