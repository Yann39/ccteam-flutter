import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/io_client.dart';

class GraphQLConnection {
  static final GraphQLConnection _graphQLSingleton = new GraphQLConnection._internal();

  GraphQLClient _graphQLClient;
  ValueNotifier<GraphQLClient> _client;
  String _jwtToken;

  factory GraphQLConnection() {
    return _graphQLSingleton;
  }

  GraphQLConnection._internal() {
    final ioc = new HttpClient();
    ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final http = new IOClient(ioc);

    final HttpLink httpLink = HttpLink(
      httpClient: http,
      uri: 'obfuscated', // for mobile device HOME
      //uri: 'obfuscated', // for local emulator
      //uri: 'obfuscated', // for production
    );

    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer $_jwtToken',
    );

    final Link link = authLink.concat(httpLink);

    _graphQLClient = GraphQLClient(
      cache: InMemoryCache(),
      link: link,
    );

    _client = ValueNotifier(graphQLClient);
  }

  GraphQLClient get graphQLClient => _graphQLClient;

  ValueNotifier<GraphQLClient> get client => _client;

  set jwtToken(String jwtToken) => _jwtToken = jwtToken;
}
