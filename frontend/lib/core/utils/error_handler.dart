import '../error/failures.dart';

class ErrorHandler {
  static String getUserFriendlyMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Network connection error. Please check your internet connection and try again.';
    } else if (failure is ServerFailure) {
      final message = failure.message.toLowerCase();
      if (message.contains('not found')) {
        return 'The requested resource was not found.';
      } else if (message.contains('unauthorized') || message.contains('forbidden')) {
        return 'You do not have permission to perform this action.';
      } else if (message.contains('timeout')) {
        return 'The request timed out. Please try again.';
      } else if (message.contains('validation')) {
        return 'Invalid input. Please check your data and try again.';
      }
      return failure.message;
    } else if (failure is CacheFailure) {
      return 'Failed to access local storage. Please try again.';
    } else if (failure is ValidationFailure) {
      return failure.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }

  static String getTechnicalMessage(Failure failure) {
    return failure.message;
  }
}

