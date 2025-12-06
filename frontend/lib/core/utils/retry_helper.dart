import 'dart:async';
import 'dart:math';

class RetryHelper {
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;
    final random = Random();

    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        
        if (attempt >= maxRetries) {
          rethrow;
        }

        if (shouldRetry != null && !shouldRetry(e)) {
          rethrow;
        }

        // Add jitter to prevent thundering herd
        final jitter = Duration(milliseconds: random.nextInt(500));
        await Future.delayed(delay + jitter);
        delay = Duration(milliseconds: (delay.inMilliseconds * backoffMultiplier).round());
      }
    }

    throw Exception('Max retries exceeded');
  }
}

