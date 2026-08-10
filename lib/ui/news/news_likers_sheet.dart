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

import 'package:ccteam/models/liked_news.dart';
import 'package:ccteam/models/member.dart';
import 'package:ccteam/models/news.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/material.dart';

/// Show a modal bottom sheet listing the members who liked [news]
/// (initials avatar + full name, sorted alphabetically).
void showNewsLikersSheet(BuildContext context, News news) {
  final List<Member> likers =
      (news.likedNews ?? <LikedNews>[])
          .map((LikedNews l) => l.member)
          .whereType<Member>()
          .toList()
        ..sort((a, b) {
          final String an = "${a.firstName ?? ''} ${a.lastName ?? ''}"
              .trim()
              .toLowerCase();
          final String bn = "${b.firstName ?? ''} ${b.lastName ?? ''}"
              .trim()
              .toLowerCase();
          return an.compareTo(bn);
        });

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext sheetContext) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[100]!, Colors.blue[200]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
        ),
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 12.0,
          bottom: MediaQuery.of(sheetContext).padding.bottom + 16.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // grab handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12.0),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Icon(Icons.favorite, color: Colors.pink[400], size: 20.0),
                const SizedBox(width: 8.0),
                Text(
                  "${AppString.newsLikersTitle} (${likers.length})",
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            if (likers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  AppString.newsNoLikers,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: likers.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  itemBuilder: (BuildContext _, int i) {
                    final Member m = likers[i];
                    final String first = m.firstName ?? '';
                    final String last = m.lastName ?? '';
                    final String fullName = "$first $last".trim();
                    final String initials =
                        "${first.isNotEmpty ? first[0] : ''}${last.isNotEmpty ? last[0] : ''}"
                            .toUpperCase();
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 18.0,
                        backgroundColor: Colors.blue[700],
                        child: Text(
                          initials.isEmpty ? '?' : initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        fullName.isEmpty ? AppString.notDefined : fullName,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    },
  );
}
