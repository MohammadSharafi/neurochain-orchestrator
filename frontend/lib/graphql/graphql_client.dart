import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';
import '../core/config/app_config.dart';

class GraphQLClientProvider {
  static GraphQLClient createClient() {
    final HttpLink httpLink = HttpLink(
      AppConfig.graphqlUrl,
      defaultHeaders: {
        'Content-Type': 'application/json',
      },
    );

    final WebSocketLink wsLink = WebSocketLink(
      AppConfig.wsUrl,
      config: SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: const Duration(seconds: 30),
      ),
    );

    final Link link = Link.split(
      (request) => request.isSubscription,
      wsLink,
      httpLink,
    );

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
      defaultOptions: DefaultOptions(
        watchQuery: WatchQueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          errorPolicy: ErrorPolicy.all,
        ),
        query: QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          errorPolicy: ErrorPolicy.all,
        ),
        mutate: MutationOptions(
          fetchPolicy: FetchPolicy.noCache,
          errorPolicy: ErrorPolicy.all,
        ),
      ),
    );
  }
}

