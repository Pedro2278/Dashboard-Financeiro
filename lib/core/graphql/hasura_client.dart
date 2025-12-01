import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class HasuraClient {
  static final HasuraClient _instance = HasuraClient._internal();
  factory HasuraClient() => _instance;
  HasuraClient._internal();

  GraphQLClient? _client;

  Future<void> init(String uri, {String? authToken}) async {
    final httpLink = HttpLink(uri);

    Link link = httpLink;

    if (authToken != null && authToken.isNotEmpty) {
      final authLink = AuthLink(getToken: () async => 'Bearer $authToken');
      link = authLink.concat(httpLink);
    }

    _client = GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    );

    if (kDebugMode) {
      print('HasuraClient initialized for $uri');
    }
  }

  GraphQLClient get client {
    if (_client == null) {
      throw Exception('HasuraClient not initialized. Call init(uri) first.');
    }
    return _client!;
  }
}
