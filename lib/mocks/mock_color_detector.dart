// test/mocks/mock_color_detector.dart

typedef ColorDetector = Future<String> Function(String url);

class MockColorDetector {
  final Map<String, String> urlToColor;
  final Duration? delay;
  final List<String> urlsToFail; // URLs that should simulate a failure

  MockColorDetector(
    this.urlToColor, {
    this.delay,
    this.urlsToFail = const [],
  });

  Future<String> getColor(String url) async {
    // Simulate optional delay
    if (delay != null) {
      await Future.delayed(delay!);
    }

    // Simulate failure for specified URLs
    for (final failUrl in urlsToFail) {
      if (url.contains(failUrl)) {
        throw Exception('Simulated color detection failure for $url');
      }
    }

    // Return mapped color if matched
    for (final entry in urlToColor.entries) {
      if (url.contains(entry.key)) {
        return entry.value;
      }
    }

    // Default fallback
    return 'unknown';
  }
}
