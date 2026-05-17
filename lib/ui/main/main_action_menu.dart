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

import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MainActionMenu extends StatelessWidget {
  /// Launch the contact email composer.
  Future<void> _openContactMail(BuildContext context) async {
    final Uri uri = Uri.parse("mailto:admin@ccteam.club");
    final MessageProvider messageProvider = Provider.of<MessageProvider>(context, listen: false);
    try {
      // skip the canLaunchUrl gate and let the OS pick a handler
      final bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        messageProvider.setMessage(AppString.noMailAppFound, MessageType.WARNING);
      }
    } catch (_) {
      messageProvider.setMessage(AppString.noMailAppFound, MessageType.WARNING);
    }
  }

  void _handleSelection(BuildContext context, QuickActions choice) {
    switch (choice) {
      case QuickActions.contact:
        _openContactMail(context);
        break;
      case QuickActions.about:
        // not wired yet, left intentionally as a no-op
        break;
      case QuickActions.logout:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<QuickActions>(
      onSelected: (QuickActions choice) => _handleSelection(context, choice),
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<QuickActions>(child: Text(AppString.about), value: QuickActions.about),
          PopupMenuItem<QuickActions>(child: Text(AppString.contact), value: QuickActions.contact),
        ];
      },
    );
  }
}
