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

import 'package:chachatte_team/models/event.dart';
import 'package:chachatte_team/utils/app_utils.dart';
import 'package:chachatte_team/utils/graphql_connection.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';

class EventsService {
  static final Logger _log = new Logger('EventsService');

  /// Fetch all events from the database.
  Future<List<Event>> fetchEvents() async {
    _log.info("Getting all events from database...");

    final String allEventQuery = """
      query GetAllEvents() {
        getAllEvents() {
          id
          title
          startDate
          endDate
          track {
            id
            name
          }
          organizer
          price
          members {
            id
          }
        }
      }
    """;

    return GraphQLConnection().graphQLClient.query(QueryOptions(document: parseString(allEventQuery))).then(
      (result) {
        final List<Event> events = [];
        if (result.hasException) {
          throw AppUtils.handleGraphQlException(result);
        } else {
          dynamic eventList = result.data['getAllEvents'];
          if (eventList == null) {
            _log.info("getAllEvents returned null data");
          } else if (eventList is Map<String, dynamic> && eventList.isEmpty) {
            _log.info("getAllEvents returned empty data");
          } else {
            for (dynamic event in eventList) {
              events.add(Event.fromJson(event));
            }
          }
          return events;
        }
      },
      onError: (error) {
        _log.severe("Error while fetching event list : $error");
        throw Exception(error);
      },
    );
  }

  /// Get an event from the database given its [id].
  Future<Event> getEventById(int id) async {
    _log.info("Getting event $id from database...");

    final String eventByIdQuery = """
      query GetEventById(\$id: Int!) {
        getEventById(id: \$id) {
          id
          title
          description
          startDate
          endDate
          track {
            id
            name
          }
          organizer
          price
          members {
            firstName
            lastName
          }
        }
      }
    """;

    return GraphQLConnection()
        .graphQLClient
        .query(
          QueryOptions(
            document: parseString(eventByIdQuery),
            variables: {'id': id},
          ),
        )
        .then(
      (result) {
        if (result.hasException) {
          throw AppUtils.handleGraphQlException(result);
        } else {
          if (result.data['getEventById'] == null) {
            return null;
          }
          return Event.fromJson(result.data['getEventById']);
        }
      },
      onError: (error) {
        throw Exception(error);
      },
    );
  }

  /// Create the specified [event] into the database.
  /// Return the created event.
  Future<void> createEvent(Event event) async {
    _log.info("Creating event ${event.title} ...");

    final String newEventMutation = """
      mutation CreateEvent(\$title: String!, \$description: String!, \$startDate: String!, \$endDate: String!, \$trackId: Long!, \$organizer: String!, \$price: Float!, \$memberId: Long!) {
        createEvent(
            title: \$title
            description: \$description
            startDate: \$startDate
            endDate: \$endDate
            trackId: \$trackId
            organizer: \$organizer
            price: \$price
            memberId: \$memberId
        )
        {
          id
          title
          description
          startDate
          endDate
          track {
            name
            distance
            lapRecord
            website
            latitude
            longitude
          }
          organizer
          price
          createdOn
          createdBy {
            id
            firstName
            lastName
          }
          modifiedOn
          modifiedBy {
            id
            firstName
            lastName
          }          
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(newEventMutation),
      variables: {
        'title': event.title,
        'description': event.description,
        'startDate': event.startDate.toIso8601String(),
        'endDate': event.endDate.toIso8601String(),
        'trackId': event.track.id,
        'organizer': event.organizer,
        'price': event.price,
        'memberId': event.createdBy.id
      },
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result);
    } else {
      return Event.fromJson(result.data['createEvent']);
    }
  }

  /// Update the specified [event] into the database.
  /// Return the updated event.
  Future<void> updateEvent(Event event) async {
    _log.info("Updating event ${event.title} ...");

    final String newEventMutation = """
      mutation UpdateEvent(\$eventId: Long!, \$title: String!, \$description: String!, \$startDate: String!, \$endDate: String!, \$trackId: Long!, \$organizer: String!, \$price: Float!, \$memberId: Long!) {
        updateEvent(
            eventId: \$eventId
            title: \$title
            description: \$description
            startDate: \$startDate
            endDate: \$endDate
            trackId: \$trackId
            organizer: \$organizer
            price: \$price
            memberId: \$memberId
        )
        {
          id
          title
          description
          startDate
          endDate
          track {
            name
            distance
            lapRecord
            website
            latitude
            longitude
          }
          organizer
          price
          createdOn
          createdBy {
            id
            firstName
            lastName
          }
          modifiedOn
          modifiedBy {
            id
            firstName
            lastName
          }          
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(newEventMutation),
      variables: {
        'eventId': event.id,
        'title': event.title,
        'description': event.description,
        'startDate': event.startDate.toIso8601String(),
        'endDate': event.endDate.toIso8601String(),
        'trackId': event.track.id,
        'organizer': event.organizer,
        'price': event.price,
        'memberId': event.modifiedBy.id
      },
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result);
    } else {
      return Event.fromJson(result.data['createEvent']);
    }
  }

  /// Delete specified [event] from the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 204
  Future<void> deleteEvent(Event event) async {
    _log.info("Deleting event ${event.title} ...");

    final String editEventMutation = """
      mutation DeleteEvent(\$eventId: Long!) {
        deleteEvent(
            eventId: \$eventId
        )
        {
          id
          title
          description
          startDate
          endDate
          track {
            name
            distance
            lapRecord
            website
            latitude
            longitude
          }
          organizer
          price
          createdOn
          createdBy {
            id
            firstName
            lastName
          }
          modifiedOn
          modifiedBy {
            id
            firstName
            lastName
          }          
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(editEventMutation),
      variables: {
        'eventId': event.id,
      },
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result);
    } else {
      return Event.fromJson(result.data['deleteEvent']);
    }
  }

/*
  /// Fetch all events for the specified [memberId] from the database
  /// Send a GET request to the Restful API
  /// Throw an exception if response status code is different from 200 or 404
  /// Return empty array if no data found (404)
  Future<List<Event>> fetchMemberEvents(int memberId) async {
    // call to API
    final response = await http.get(Uri.parse(API_ROOT_URL + API_GET_MEMBER_EVENTS_ENDPOINT + "?memberId=$memberId"));

    if (response.statusCode == 200) {
      // if the call to the server was successful, parse the JSON and return content
      dynamic responseJson = json.decode(response.body);
      return (responseJson['records'] as List).map((p) => Event.fromJson(p)).toList();
    } else if (response.statusCode == 404) {
      // no data found, return empty array
      return [];
    } else if (response.statusCode == 400) {
      throw Exception('Bad request, check that parameter has been specified correctly');
    } else {
      throw Exception('Unexpected server response');
    }
  }

  /// Fetch all events for the specified [trackId] from the database
  /// Send a GET request to the Restful API
  /// Throw an exception if response status code is different from 200 or 404
  /// Return empty array if no data found (404)
  Future<List<Event>> fetchTrackEvents(int trackId) async {
    // call to API
    final response = await http.get(Uri.parse(API_ROOT_URL + API_GET_TRACK_EVENTS_ENDPOINT + "?trackId=$trackId"));

    if (response.statusCode == 200) {
      // if the call to the server was successful, parse the JSON and return content
      dynamic responseJson = json.decode(response.body);
      return (responseJson['records'] as List).map((p) => Event.fromJson(p)).toList();
    } else if (response.statusCode == 404) {
      // no data found, return empty array
      return [];
    } else if (response.statusCode == 400) {
      throw Exception('Bad request, check that parameter has been specified correctly');
    } else {
      throw Exception('Unexpected server response');
    }
  }
   */
}
