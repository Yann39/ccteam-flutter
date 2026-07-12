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

import 'package:ccteam/models/trusted_device.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/members_service.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/device_identity.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/info_banner.dart';
import 'package:ccteam/widgets/loading_content.dart';
import 'package:ccteam/widgets/restricted_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Lists the member's trusted devices (device binding) and lets them revoke
/// any device except the one currently in use. A revoked device must be
/// re-verified by e-mail on its next login.
class TrustedDevices extends StatefulWidget {
  const TrustedDevices({Key? key}) : super(key: key);

  @override
  State<TrustedDevices> createState() => _TrustedDevicesState();
}

class _TrustedDevicesState extends State<TrustedDevices> {
  final MembersService _membersService = new MembersService();

  LoadingStatus _status = LoadingStatus.loading;
  List<TrustedDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _status = LoadingStatus.loading);
    try {
      final String secret = await DeviceIdentity.getOrCreateSecret();
      final List<TrustedDevice> devices = await _membersService.getMyTrustedDevices(secret);
      if (!mounted) return;
      setState(() {
        _devices = devices;
        _status = devices.isEmpty ? LoadingStatus.empty : LoadingStatus.loaded;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = LoadingStatus.notLoaded);
      Provider.of<MessageProvider>(context, listen: false).setMessage(
        AppString.trustedDevicesLoadFailed,
        MessageType.ERROR,
      );
    }
  }

  Future<void> _confirmAndRevoke(TrustedDevice device) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppString.trustedDeviceRevokeTitle),
          content: Text(AppString.trustedDeviceRevokeConfirm),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(AppString.cancel)),
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(AppString.confirm)),
          ],
        );
      },
    );
    if (confirmed != true) return;

    final MessageProvider messageProvider = Provider.of<MessageProvider>(context, listen: false);
    try {
      final bool ok = await _membersService.revokeTrustedDevice(device.id);
      if (ok) {
        messageProvider.setMessage(AppString.trustedDeviceRevoked, MessageType.SUCCESS);
        await _load();
      } else {
        messageProvider.setMessage(AppString.trustedDeviceRevokeFailed, MessageType.ERROR);
      }
    } catch (_) {
      messageProvider.setMessage(AppString.trustedDeviceRevokeFailed, MessageType.ERROR);
    }
  }

  Widget _buildDeviceCard(TrustedDevice device) {
    final String? added = device.createdOn != null
        ? AppDateUtils.convertToString(device.createdOn!, 'dd MMM yyyy')
        : null;
    final String? lastUsed = device.lastUsedOn != null
        ? AppDateUtils.convertToString(device.lastUsedOn!, 'dd MMM yyyy HH:mm')
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: CustomDecorations.cardLight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (device.current ? Colors.green[700]! : Colors.blueGrey[500]!).withValues(alpha: 0.15),
            ),
            child: Icon(
              Icons.smartphone,
              size: 22.0,
              color: device.current ? Colors.green[700] : Colors.blueGrey[600],
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        device.label?.isNotEmpty == true ? device.label! : AppString.notDefined,
                        style: TextStyle(color: Colors.black.withAlpha(220), fontSize: 14.0, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (device.current) ...[
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: Colors.green[700]!.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          AppString.trustedDeviceCurrent,
                          style: TextStyle(color: Colors.green[800], fontSize: 11.0, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
                if (added != null) ...[
                  const SizedBox(height: 3.0),
                  Text(
                    AppString.format(AppString.trustedDeviceAddedOn, [added]),
                    style: TextStyle(color: Colors.black.withAlpha(150), fontSize: 12.0),
                  ),
                ],
                if (lastUsed != null) ...[
                  const SizedBox(height: 1.0),
                  Text(
                    AppString.format(AppString.trustedDeviceLastUsed, [lastUsed]),
                    style: TextStyle(color: Colors.black.withAlpha(150), fontSize: 12.0),
                  ),
                ],
              ],
            ),
          ),
          // the current device can't be revoked from itself (it would just re-enroll and lock nothing);
          // revocation targets other devices (e.g. a lost phone)
          if (!device.current)
            IconButton(
              tooltip: AppString.trustedDeviceRevoke,
              icon: Icon(Icons.delete_outline, color: Colors.red[700]),
              onPressed: () => _confirmAndRevoke(device),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);

    final Widget body;
    if (!_loginProvider.isMember) {
      body = RestrictedContent();
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const InfoBanner(message: AppString.trustedDevicesHelp),
          const SizedBox(height: 8.0),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: LoadingContent(
                loadingStatus: _status,
                defaultText: AppString.trustedDevicesLoadFailed,
                emptyText: AppString.trustedDevicesEmpty,
                child: ListView(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16.0),
                  children: <Widget>[for (final TrustedDevice d in _devices) _buildDeviceCard(d)],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.trustedDevices),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Container(padding: const EdgeInsets.all(8.0), decoration: CustomDecorations.mainContent, child: body),
    );
  }
}
