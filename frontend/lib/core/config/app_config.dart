class AppConfig {
  static const String graphqlUrl = 'http://localhost:8080/graphql';
  static const String wsUrl = 'ws://localhost:8080/graphql-ws';
  static const String aiWorkerUrl = 'http://localhost:5000';
  
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

