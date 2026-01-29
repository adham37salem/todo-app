/// # API Host - Web (api_host_web.dart)
///
/// Used when the app runs in the **browser** (Chrome, Edge, etc.). On web we cannot
/// use [dart:io] [Platform], so this file provides the same [apiHost] getter with
/// a fixed value. When you run the app in the browser, the backend is usually on
/// the same machine, so 'localhost' is correct.

/// Host for the API when running on web (same machine as backend).
String get apiHost => 'localhost';
