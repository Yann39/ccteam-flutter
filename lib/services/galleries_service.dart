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

import 'dart:convert';

import 'package:ccteam/utils/constants.dart';
import 'package:http/http.dart' as http;

import '../models/gallery.dart';
import '../models/photo.dart';

class GalleriesService {
  /// Map of cookies to maintain the session
  Map<String, String> _cookies = {};

  /// Initialize the Lychee session by fetching the root page and extracting CSRF token
  Future<String?> _initSession() async {
    // If we already have cookies and an XSRF token, reuse them
    if (_cookies.containsKey('XSRF-TOKEN')) {
      return Uri.decodeComponent(_cookies['XSRF-TOKEN']!);
    }

    final response = await http.get(Uri.parse(LYCHEE_BASE_URL + "/"));

    if (response.headers.containsKey('set-cookie')) {
      final setCookie = response.headers['set-cookie']!;
      // Simple cookie extraction
      final cookies = setCookie.split(',');
      for (var cookie in cookies) {
        final parts = cookie.split(';')[0].split('=');
        if (parts.length == 2) {
          _cookies[parts[0].trim()] = parts[1].trim();
        }
      }
    }

    if (_cookies.containsKey('XSRF-TOKEN')) {
      return Uri.decodeComponent(_cookies['XSRF-TOKEN']!);
    }
    return null;
  }

  /// Fetch all galleries from the Lychee API
  Future<List<Gallery>> fetchGalleries() async {
    final xsrfToken = await _initSession();

    if (xsrfToken == null) {
      throw Exception('Failed to initialize Lychee session');
    }

    final cookieHeader = _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');

    final response = await http.get(
      Uri.parse(LYCHEE_BASE_URL + LYCHEE_ALBUMS_ENDPOINT),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'X-XSRF-TOKEN': xsrfToken,
        'Cookie': cookieHeader,
      },
    );

    if (response.statusCode == 200) {
      final dynamic responseJson = json.decode(response.body);
      final List<dynamic> albumsJson = responseJson['albums'] ?? [];

      return albumsJson.map((album) {
        // Map Lychee album to CCTeam Gallery
        return Gallery(
          id: album['id'],
          title: album['title'],
          description: album['description'] ?? '',
          // populate the photos list with the thumbnail as the first entry
          // to maintain compatibility with the UI's stack preview
          photos: [
            if (album['thumb'] != null && album['thumb']['thumb'] != null)
              Photo(id: album['thumb']['id']?.toString() ?? 'thumb', title: 'Thumbnail', link: album['thumb']['thumb']),
          ],
        );
      }).toList();
    } else if (response.statusCode == 401 || response.statusCode == 419) {
      // if session expired, clear cookies and retry once
      _cookies.clear();
      return fetchGalleries();
    } else {
      throw Exception('Failed to fetch albums from Lychee: ${response.statusCode}');
    }
  }

  /// Fetch all photos for a specific album from Lychee
  Future<List<Photo>> fetchPhotosForAlbum(String albumId) async {
    final xsrfToken = await _initSession();
    if (xsrfToken == null) throw Exception('Failed to initialize Lychee session');

    final cookieHeader = _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');

    final response = await http.get(
      Uri.parse(LYCHEE_BASE_URL + LYCHEE_ALBUM_ENDPOINT).replace(queryParameters: {'album_id': albumId}),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'X-XSRF-TOKEN': xsrfToken,
        'Cookie': cookieHeader,
      },
    );

    if (response.statusCode == 200) {
      final dynamic responseJson = json.decode(response.body);

      // Lychee v2 returns the album resource inside a 'resource' field
      final resource = responseJson['resource'];
      if (resource == null) return [];

      final List<dynamic> photosJson = resource['photos'] ?? [];

      return photosJson.map((p) {
        // Find a suitable URL (medium variant if available, otherwise original)
        String? link;
        if (p['size_variants'] != null) {
          if (p['size_variants']['medium'] != null) {
            link = p['size_variants']['medium']['url'];
          } else if (p['size_variants']['original'] != null) {
            link = p['size_variants']['original']['url'];
          }
        }

        return Photo(
          id: p['id'].toString(),
          title: p['title'],
          description: p['description'] ?? '',
          link: link != null ? (link.startsWith('http') ? link : LYCHEE_BASE_URL + '/' + link) : '',
          createdOn: p['created_at'] != null ? DateTime.parse(p['created_at']) : null,
        );
      }).toList();
    } else if (response.statusCode == 401 || response.statusCode == 419) {
      _cookies.clear();
      return fetchPhotosForAlbum(albumId);
    } else {
      throw Exception('Failed to fetch photos for album $albumId: ${response.statusCode}');
    }
  }
}
