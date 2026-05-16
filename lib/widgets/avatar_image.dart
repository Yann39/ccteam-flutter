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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/graphql_connection.dart';
import 'package:flutter/material.dart';

/// Renders a member avatar fetched from the `/avatars/{id}` REST
/// endpoint, with disk + memory caching via `cached_network_image`.
///
/// Falls back to a neutral pilot-glyph placeholder when:
///  - [memberId] is null (e.g. the Member model isn't fully loaded yet),
///  - [hasAvatar] is false (the server has no avatar for that member),
///  - the network fetch fails (404, 401, timeout, …).
class AvatarImage extends StatelessWidget {
  const AvatarImage({
    Key? key,
    required this.memberId,
    required this.hasAvatar,
    this.radius = 30.0,
    this.backgroundColor,
    this.placeholderIconColor = Colors.white,
  }) : super(key: key);

  /// Member id used to build the avatar URL. When null, the
  /// placeholder is rendered (no network call).
  final int? memberId;

  /// Whether the server has an avatar for this member. Drives the
  /// branch between "fetch from network" and "render placeholder".
  /// Sourced from the `hasAvatar` field on the GraphQL Member type.
  final bool hasAvatar;

  /// Circle radius. Matches what callers were passing to `CircleAvatar`.
  final double radius;

  /// Background colour for both the placeholder and the loaded image
  /// (visible while the network fetch is in flight). Defaults to
  /// `Colors.blue[100]` if unset, same as the historical default.
  final Color? backgroundColor;

  /// Colour applied to the pilot glyph in the placeholder. White by
  /// default, works against the blue background. Pass a darker tone
  /// when the avatar is rendered on a light card.
  final Color placeholderIconColor;

  /// Build the absolute avatar URL for the given member.
  static String urlFor(int memberId) => '$API_BASE_URL$API_AVATARS_ENDPOINT/$memberId';

  /// Drop any cached bytes for [memberId]'s avatar — both the
  /// in-memory image cache and the on-disk store managed by
  /// `cached_network_image` / `flutter_cache_manager`.
  ///
  /// Needed after a successful avatar upload: the server-side ETag
  /// changes (new attachment + new upload timestamp), but the URL
  /// stays the same, so the local cache would otherwise keep
  /// serving the previous bytes until the 1-hour `max-age` expires.
  /// Calling this right after the mutation completes flips the user
  /// to the new avatar immediately on the next render.
  static Future<void> evictCache(int memberId) async {
    await CachedNetworkImage.evictFromCache(urlFor(memberId));
  }

  /// HTTP headers sent with the avatar request. Mirrors the
  /// `Authorization: Bearer …` injected by `AuthLink` for GraphQL,
  /// so the REST endpoint sees the same JWT-authenticated caller.
  /// Empty map (no token) means the request will 401, handled
  /// gracefully by [CachedNetworkImage.errorWidget].
  static Map<String, String> _authHeaders() {
    final String? token = GraphQLConnection().jwtToken;
    if (token == null) return const <String, String>{};
    return <String, String>{'Authorization': 'Bearer $token'};
  }

  @override
  Widget build(BuildContext context) {
    final Color bg = backgroundColor ?? Colors.blue[100]!;

    if (memberId == null || !hasAvatar) {
      return _placeholder(bg);
    }

    return ClipOval(
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: CachedNetworkImage(
          imageUrl: urlFor(memberId!),
          httpHeaders: _authHeaders(),
          fit: BoxFit.cover,
          // while the bytes are loading from network (or disk cache, very brief), render the same placeholder so there's no visual jump or empty hole
          placeholder: (_, __) => _placeholder(bg),
          // 404 / 401 / network error → also render the placeholder
          errorWidget: (_, __, ___) => _placeholder(bg),
        ),
      ),
    );
  }

  /// Neutral circular placeholder.
  Widget _placeholder(Color bg) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: Icon(CustomIcons.pilot, size: radius * 1.15, color: placeholderIconColor),
    );
  }
}
