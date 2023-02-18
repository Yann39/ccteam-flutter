/*
 * Copyright (c) 2019 by Yann39.
 *
 * This file is part of Chachatte Team application.
 *
 * Chachatte Team is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Chachatte Team is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Chachatte Team. If not, see <http://www.gnu.org/licenses/>.
 */


import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'constants.dart';

class GraphQLConnection {
  static final GraphQLConnection _graphQLSingleton =
      new GraphQLConnection._internal();

  GraphQLClient _graphQLClient;
  ValueNotifier<GraphQLClient> _client;
  String _jwtToken;

  factory GraphQLConnection() {
    return _graphQLSingleton;
  }

  GraphQLConnection._internal() {
    /*final ioc = new HttpClient();
    ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final http = new IOClient(ioc);*/

    final HttpLink httpLink = HttpLink(API_ROOT_URL + API_GRAPHQL_ENDPOINT);

    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer $_jwtToken',
    );

    final Link link = authLink.concat(httpLink);

    _graphQLClient = GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: link,
    );

    _client = ValueNotifier(graphQLClient);
  }

  GraphQLClient get graphQLClient => _graphQLClient;

  ValueNotifier<GraphQLClient> get client => _client;

  set jwtToken(String jwtToken) => _jwtToken = jwtToken;
}
