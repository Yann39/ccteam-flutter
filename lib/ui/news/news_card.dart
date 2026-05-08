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

import 'package:ccteam/models/news.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/news_list_provider.dart';
import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewsCard extends StatelessWidget {
  final int index;

  NewsCard(this.index);

  @override
  Widget build(BuildContext context) {
    final NewsListProvider newsListProvider =
        Provider.of<NewsListProvider>(context, listen: true);
    final LoginProvider loginProvider =
        Provider.of<LoginProvider>(context, listen: false);

    final News news = newsListProvider.newsList[index];
    final Color accentColor = _accentColorFor(index);
    final bool isLiked = _isLikedByCurrentUser(news, loginProvider);
    final int likesCount = news.likedNews?.length ?? 0;

    return Container(
      height: 84.0,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
      decoration: CustomDecorations.cardFull,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildLeading(
            accentColor: accentColor,
            isLiked: isLiked,
            likesCount: likesCount,
          ),
          const SizedBox(width: 8.0),
          Expanded(child: _buildContent(news)),
          const SizedBox(width: 8.0),
          const Icon(Icons.chevron_right, color: Colors.white, size: 20.0),
        ],
      ),
    );
  }

  /// Cycles through three accent colors so each news has a different
  /// helmet tint than its neighbours.
  Color _accentColorFor(int index) {
    switch (index % 3) {
      case 0:
        return Colors.red[900]!;
      case 1:
        return Colors.green[600]!;
      default:
        return Colors.blue[600]!;
    }
  }

  bool _isLikedByCurrentUser(News news, LoginProvider loginProvider) {
    return news.likedNews?.any(
          (element) => element.member!.id == loginProvider.loggedMember!.id,
        ) ??
        false;
  }

  /// Left column of the card: helmet icon (gradient-tinted) on top, like
  /// counter at the bottom.
  Widget _buildLeading({
    required Color accentColor,
    required bool isLiked,
    required int likesCount,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
            stops: const [0.0, 1.0],
            colors: [accentColor, Colors.purple[700]!],
          ).createShader(bounds),
          child: Icon(
            CustomIcons.helmet,
            size: 35,
            color: accentColor,
          ),
        ),
        _buildMetaItem(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          iconColor: Colors.pink,
          text: "$likesCount",
        ),
      ],
    );
  }

  /// Middle column of the card: bold title, catch line and date.
  Widget _buildContent(News news) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          news.title ?? "",
          textScaler: const TextScaler.linear(1.2),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4.0),
        Text(
          news.catchLine ?? "",
          textScaler: const TextScaler.linear(0.9),
          style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4.0),
        _buildMetaItem(
          icon: Icons.access_time,
          iconColor: Colors.lime,
          text: news.newsDate != null
              ? (AppDateUtils.convertToString(news.newsDate!, DATE_FORMAT) ?? "")
              : "",
        ),
      ],
    );
  }

  /// Reusable "small icon + caption" pair used for both the like counter
  /// (left column) and the date (middle column).
  Widget _buildMetaItem({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, color: iconColor, size: 12.0),
        const SizedBox(width: 2.0),
        Text(
          text,
          softWrap: false,
          textScaler: const TextScaler.linear(0.9),
          style: const TextStyle(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
