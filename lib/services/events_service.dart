/*
 * Copyright (c) 2019 by Yann39.
 *
 * This file is part of CCTeam application.
 *
 * CCTeam is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * CCTeam is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with CCTeam. If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:ccteam/models/event.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/graphql_connection.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';

import '../utils/custom_graphql_exception.dart';

class EventsService {
  static final Logger _log = new Logger('EventsService');

  /// Lightweight count of all events. USER-accessible so the home
  /// stats panel can still display a total when the caller is not a MEMBER.
  Future<int?> fetchEventsCount() async {
    _log.info("Getting events count from database...");

    final String query = """
      query GetEventsCount {
        getEventsCount
      }
    """;

    final QueryResult result = await GraphQLConnection().graphQLClient.query(
      QueryOptions(document: parseString(query), fetchPolicy: FetchPolicy.noCache),
    );
    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    }
    final dynamic v = result.data?['getEventsCount'];
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  /// Fetch all events from the database.
  Future<List<Event>> fetchEvents() async {
    _log.info("Getting all events from database...");

    final String query = """
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
          organizer {
            id
            name
          }
          price
          participants {
            member {
              id
            }
          }
        }
      }
    """;

    return GraphQLConnection().graphQLClient
        .query(QueryOptions(document: parseString(query), fetchPolicy: FetchPolicy.noCache))
        .then(
          (result) {
            final List<Event> events = [];
            if (result.hasException) {
              throw AppUtils.handleGraphQlException(result)!;
            } else {
              dynamic eventList = result.data!['getAllEvents'];
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

  /// Fetch all events for a specific [trackId]
  Future<List<Event>> fetchEventsByTrack(int trackId) async {
    _log.info("Getting events for track $trackId from database...");
    return fetchEvents().then((events) {
      _log.info("Fetched ${events.length} total events. Filtering for track $trackId...");
      final filtered = events.where((e) {
        return e.track?.id == trackId;
      }).toList();
      _log.info("Found ${filtered.length} events for track $trackId");
      return filtered;
    });
  }

  /// Fetch all events from the database for the specified [year] based on event start date.
  Future<List<Event>> fetchEventsForYear(int year) async {
    _log.info("Getting all events of year $year from database...");

    final String query = """
      query GetEventsByYear(\$year: Int!) {
        getEventsByYear(year: \$year) {
          id
          title
          startDate
          endDate
          track {
            id
            name
          }
          organizer {
            id
            name
          }
          price
          participants {
            id
          }
        }
      }
    """;

    return GraphQLConnection().graphQLClient
        .query(QueryOptions(document: parseString(query), variables: {'year': year}, fetchPolicy: FetchPolicy.noCache))
        .then(
          (result) {
            final List<Event> events = [];
            if (result.hasException) {
              throw AppUtils.handleGraphQlException(result)!;
            } else {
              dynamic eventList = result.data!['getEventsByYear'];
              if (eventList == null) {
                _log.info("getEventsByYear returned null data");
              } else if (eventList is Map<String, dynamic> && eventList.isEmpty) {
                _log.info("getEventsByYear returned empty data");
              } else {
                for (dynamic event in eventList) {
                  events.add(Event.fromJson(event));
                }
              }
              return events;
            }
          },
          onError: (error) {
            _log.severe("Error while fetching event list for year $year : $error");
            throw Exception(error);
          },
        );
  }

  /// Fetch all events from the database for the specified [month] and [year] based on event start date.
  Future<List<Event>> fetchEventsForMonthAndYear(int month, int year) async {
    _log.info("Getting all events of month $month and year $year from database...");

    final String query = """
      query GetEventsByMonthAndYear(\$month: Int!, \$year: Int!) {
        getEventsByMonthAndYear(month: \$month, year: \$year) {
          id
          title
          startDate
          endDate
          track {
            id
            name
          }
          organizer {
            id
            name
          }
          price
          participants {
            id
          }
        }
      }
    """;

    return GraphQLConnection().graphQLClient
        .query(
          QueryOptions(
            document: parseString(query),
            variables: {'month': month, 'year': year},
            fetchPolicy: FetchPolicy.noCache,
          ),
        )
        .then(
          (result) {
            final List<Event> events = [];
            if (result.hasException) {
              throw AppUtils.handleGraphQlException(result)!;
            } else {
              dynamic eventList = result.data!['getEventsByMonthAndYear'];
              if (eventList == null) {
                _log.info("getEventsByMonthAndYear returned null data");
              } else if (eventList is Map<String, dynamic> && eventList.isEmpty) {
                _log.info("getEventsByMonthAndYear returned empty data");
              } else {
                for (dynamic event in eventList) {
                  events.add(Event.fromJson(event));
                }
              }
              return events;
            }
          },
          onError: (error) {
            _log.severe("Error while fetching event list for month $month and year $year : $error");
            throw Exception(error);
          },
        );
  }

  /// Fetch all events from the database for the specified [day], [month] and [year] based on event start date.
  Future<List<Event>> fetchEventsForDayAndMonthAndYear(int day, int month, int year) async {
    _log.info("Getting all events for day $day, month $month and year $year from database...");

    final String query = """
      query GetEventsByDayAndMonthAndYear(\$day: Int!, \$month: Int!, \$year: Int!) {
        getEventsByDayAndMonthAndYear(day: \$day, month: \$month, year: \$year) {
          id
          title
          startDate
          endDate
          track {
            id
            name
          }
          organizer {
            id
            name
          }
          price
          participants {
            id
          }
        }
      }
    """;

    return GraphQLConnection().graphQLClient
        .query(
          QueryOptions(
            document: parseString(query),
            variables: {'day': day, 'month': month, 'year': year},
            fetchPolicy: FetchPolicy.noCache,
          ),
        )
        .then(
          (result) {
            final List<Event> events = [];
            if (result.hasException) {
              throw AppUtils.handleGraphQlException(result)!;
            } else {
              dynamic eventList = result.data!['getEventsByDayAndMonthAndYear'];
              if (eventList == null) {
                _log.info("getEventsByDayAndMonthAndYear returned null data");
              } else if (eventList is Map<String, dynamic> && eventList.isEmpty) {
                _log.info("getEventsByDayAndMonthAndYear returned empty data");
              } else {
                for (dynamic event in eventList) {
                  events.add(Event.fromJson(event));
                }
              }
              return events;
            }
          },
          onError: (error) {
            _log.severe("Error while fetching event list for day $day, month $month and year $year : $error");
            throw Exception(error);
          },
        );
  }

  /// Get an event from the database given its [id].
  Future<Event> getEventById(int id) async {
    _log.info("Getting event $id from database...");

    final String query = """
      query GetEventById(\$id: Long!) {
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
          organizer {
            id
            name
          }
          price
          participants {
            id
            member {
              id
              firstName
              lastName
              hasAvatar
            }
            bike {
              id
              manufacturer
              modelName
              engineSize
              year
            }
          }
        }
      }
    """;

    return GraphQLConnection().graphQLClient
        .query(QueryOptions(document: parseString(query), variables: {'id': id}, fetchPolicy: FetchPolicy.noCache))
        .then(
          (result) {
            if (result.hasException) {
              throw AppUtils.handleGraphQlException(result)!;
            } else {
              // this should never happen as an exception is returned above when no data is found
              if (result.data == null || result.data!['getEventById'] == null) {
                throw CustomGraphQlException("no_event_found_with_id", "Event has not been found");
              }
              return Event.fromJson(result.data!['getEventById']);
            }
          },
          onError: (error) {
            throw Exception(error);
          },
        );
  }

  /// Create the specified [event] into the database.
  /// Return the created event.
  Future<Event> createEvent(Event event) async {
    _log.info("Creating event ${event.title} ...");

    final String query = """
      mutation CreateEvent(\$title: String!, \$description: String!, \$startDate: String!, \$endDate: String!, \$trackId: Long!, \$organizerId: Long!, \$price: Float!, \$memberId: Long!) {
        createEvent(
            title: \$title
            description: \$description
            startDate: \$startDate
            endDate: \$endDate
            trackId: \$trackId
            organizerId: \$organizerId
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
            country {
              code
              nameFr
              nameEn
            }
          }
          organizer {
            id
            name
          }
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
      document: parseString(query),
      variables: {
        'title': event.title,
        'description': event.description,
        'startDate': event.startDate!.toIso8601String(),
        'endDate': event.endDate!.toIso8601String(),
        'trackId': event.track!.id,
        'organizerId': event.organizer?.id,
        'price': event.price,
        'memberId': event.createdBy!.id,
      },
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return Event.fromJson(result.data!['createEvent']);
    }
  }

  /// Update the specified [event] into the database.
  /// Return the updated event.
  Future<Event> updateEvent(Event event) async {
    _log.info("Updating event ${event.title} ...");

    final String query = """
      mutation UpdateEvent(\$eventId: Long!, \$title: String!, \$description: String!, \$startDate: String!, \$endDate: String!, \$trackId: Long!, \$organizerId: Long!, \$price: Float!, \$memberId: Long!) {
        updateEvent(
            eventId: \$eventId
            title: \$title
            description: \$description
            startDate: \$startDate
            endDate: \$endDate
            trackId: \$trackId
            organizerId: \$organizerId
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
            country {
              code
              nameFr
              nameEn
            }
          }
          organizer {
            id
            name
          }
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
      document: parseString(query),
      variables: {
        'eventId': event.id,
        'title': event.title,
        'description': event.description,
        'startDate': event.startDate!.toIso8601String(),
        'endDate': event.endDate!.toIso8601String(),
        'trackId': event.track!.id,
        'organizerId': event.organizer?.id,
        'price': event.price,
        'memberId': event.modifiedBy!.id,
      },
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return Event.fromJson(result.data!['updateEvent']);
    }
  }

  /// Delete the specified [event] from the database.
  /// Return the original event that have been deleted.
  Future<Event> deleteEvent(Event event) async {
    _log.info("Deleting event ${event.title} ...");

    final String query = """
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
            country {
              code
              nameFr
              nameEn
            }
          }
          organizer {
            id
            name
          }
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
      document: parseString(query),
      variables: {'eventId': event.id},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return Event.fromJson(result.data!['deleteEvent']);
    }
  }

  /// Mark the specified [eventId] as registered for the member identified by the specified [memberId].
  /// Optionally pin a [bikeId] to the participation at registration
  /// time; pass {@code null} to register without a bike (the user can
  /// pick later via [setEventMemberBike]).
  /// Return the up-to-date event.
  Future<Event> registerToEvent(int eventId, int memberId, {int? bikeId}) async {
    _log.info("Registering to event $eventId for member $memberId (bike=$bikeId)...");

    final String registerMutation = """
      mutation RegisterToEvent(\$eventId: Long!, \$memberId: Long!, \$bikeId: Long) {
        registerToEvent(
            eventId: \$eventId
            memberId: \$memberId
            bikeId: \$bikeId
        )
        {
          id
          title
          description
          startDate
          endDate
          track {
            id
            name
          }
          organizer {
            id
            name
          }
          price
          participants {
            id
            member {
              id
              firstName
              lastName
              hasAvatar
            }
            bike {
              id
              manufacturer
              modelName
              engineSize
              year
            }
          }
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(registerMutation),
      variables: {'eventId': eventId, 'memberId': memberId, 'bikeId': bikeId},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return Event.fromJson(result.data!['registerToEvent']);
    }
  }

  /// Change (or clear, by passing a {@code null} [bikeId]) the bike
  /// pinned to the caller's participation in [eventId]. The server
  /// derives the acting member from the auth token, so we don't pass
  /// a memberId here. Returns the up-to-date event.
  Future<Event> setEventMemberBike(int eventId, {int? bikeId}) async {
    _log.info("Setting bike $bikeId on event $eventId for the caller...");

    final String mutation = """
      mutation SetEventMemberBike(\$eventId: Long!, \$bikeId: Long) {
        setEventMemberBike(
            eventId: \$eventId
            bikeId: \$bikeId
        )
        {
          id
          title
          description
          startDate
          endDate
          track {
            id
            name
          }
          organizer {
            id
            name
          }
          price
          participants {
            id
            member {
              id
              firstName
              lastName
              hasAvatar
            }
            bike {
              id
              manufacturer
              modelName
              engineSize
              year
            }
          }
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(mutation),
      variables: {'eventId': eventId, 'bikeId': bikeId},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return Event.fromJson(result.data!['setEventMemberBike']);
    }
  }

  /// Mark the specified [eventId] as unregistered for the member identified by the specified [memberId].
  /// Return the up-to-date event.
  Future<Event> unregisterFromEvent(int eventId, int memberId) async {
    _log.info("Unregistering from event $eventId for member $memberId ...");

    final String unregisterMutation = """
      mutation UnregisterFromEvent(\$eventId: Long!, \$memberId: Long!) {
        unregisterFromEvent(
            eventId: \$eventId
            memberId: \$memberId
        )
        {
          id
          title
          description
          startDate
          endDate
          track {
            id
            name
          }
          organizer {
            id
            name
          }
          price
          participants {
            id
            member {
              id
              firstName
              lastName
              hasAvatar
            }
            bike {
              id
              manufacturer
              modelName
              engineSize
              year
            }
          }
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(unregisterMutation),
      variables: {'eventId': eventId, 'memberId': memberId},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return Event.fromJson(result.data!['unregisterFromEvent']);
    }
  }
}
