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
import 'dart:io';

import 'package:ccteam/providers/avatar_provider.dart';
import 'package:ccteam/providers/member_creation_provider.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditAvatar extends StatelessWidget {
  const EditAvatar({Key? key}) : super(key: key);

  /// Allow user to select an image from the gallery
  Future _selectImageFromGallery(
      BuildContext context, AvatarProvider avatarProvider) async {
    final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 50);
    if (image != null) {
      avatarProvider.setPickedImage(File(image.path));
      avatarProvider.setPickedImageName(image.name);
      Navigator.of(context).pushNamed('/imageCrop');
    }
  }

  /// Allow user to select an image from the camera
  Future _selectImageFromCamera(
      BuildContext context, AvatarProvider avatarProvider) async {
    final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 50);
    if (image != null) {
      avatarProvider.setPickedImage(File(image.path));
      avatarProvider.setPickedImageName(image.name);
      Navigator.of(context).pushNamed('/imageCrop');
    }
  }

  /// Display a confirmation popup when trying to reset an avatar
  void _showConfirmation(
      BuildContext context, AvatarProvider avatarProvider, String value) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppString.confirmation),
        content: Text(value),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              _dialogueResult(context, avatarProvider, ConfirmDialogAction.yes);
            },
            child: Text(AppString.confirm),
          ),
          TextButton(
            onPressed: () {
              _dialogueResult(context, avatarProvider, ConfirmDialogAction.no);
            },
            child: Text(AppString.cancel),
          ),
        ],
      ),
    );
  }

  /// Handle result of the avatar reset confirmation dialog
  void _dialogueResult(BuildContext context, AvatarProvider avatarProvider,
      ConfirmDialogAction value) {
    if (value == ConfirmDialogAction.yes) {
      avatarProvider.setPickedImage(null);
      avatarProvider.setPickedImageName(null);
      avatarProvider.setCroppedImage(null);
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
    }
  }

  /// Strip the leading "Formats " prefix to keep the constraints subtitle
  /// compact (e.g. "Max. 500 Ko · JPG, GIF, PNG").
  String _formatsShort() {
    final String formats = AppString.avatarFormats;
    return formats.startsWith("Formats ")
        ? formats.substring("Formats ".length)
        : formats;
  }

  @override
  Widget build(BuildContext context) {
    final _avatarProvider =
        Provider.of<AvatarProvider>(context, listen: true);
    final _memberCreationProvider =
        Provider.of<MemberCreationProvider>(context, listen: false);

    final bool _hasImage = _avatarProvider.croppedImage != null ||
        _avatarProvider.pickedImage != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.profilePhoto),
        actions: <Widget>[
          if (_hasImage)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: AppString.initProfilePhoto,
              onPressed: () => _showConfirmation(
                  context, _avatarProvider, AppString.avatarResetAreYouSure),
            ),
        ],
      ),
      body: Container(
        // explicit infinity so the gradient covers the full body height
        // even when the scrollview's content is shorter than the screen
        // (otherwise the Container shrinks to its child and a white
        // strip shows at the bottom)
        width: double.infinity,
        height: double.infinity,
        decoration: CustomDecorations.mainContent,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Circular avatar preview
                Center(
                  child: _AvatarPreview(provider: _avatarProvider),
                ),
                const SizedBox(height: 24.0),

                // Heading + constraints (one compact line)
                Text(
                  AppString.selectPhoto,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withAlpha(204),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  "${AppString.maxAvatarSize} · ${_formatsShort()}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.black.withAlpha(140),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Source picker cards
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _SourceCard(
                        icon: Icons.photo_library_rounded,
                        label: AppString.gallery,
                        color: Colors.blue[700]!,
                        onTap: () => _selectImageFromGallery(
                            context, _avatarProvider),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: _SourceCard(
                        icon: Icons.photo_camera_rounded,
                        label: AppString.camera,
                        color: Colors.deepPurple[600]!,
                        onTap: () => _selectImageFromCamera(
                            context, _avatarProvider),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28.0),

                // Confirm button (full-width primary action)
                ElevatedButton.icon(
                  onPressed: () {
                    final String? newAvatar =
                        _avatarProvider.croppedImage != null
                            ? base64Encode(_avatarProvider.croppedImage!)
                            : null;
                    final String? newAvatarName =
                        _avatarProvider.croppedImage != null
                            ? _avatarProvider.pickedImageName
                            : null;

                    _memberCreationProvider.setCurrentMemberAvatar(
                      newAvatar,
                      newAvatarName,
                    );

                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check, size: 18, color: Colors.white),
                  label: Text(
                    AppString.confirmSelection,
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                    elevation: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular avatar preview shown at the top of the page. Renders, in order
/// of priority: the cropped image (final result), the freshly-picked image
/// (intermediate state before crop), or a pilot-icon placeholder. Frame:
/// white border + soft drop shadow so it visually pops on the blue
/// gradient background.
class _AvatarPreview extends StatelessWidget {
  final AvatarProvider provider;
  const _AvatarPreview({Key? key, required this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double size = 200.0;

    Widget content;
    if (provider.croppedImage != null) {
      content = Image.memory(
        provider.croppedImage!,
        fit: BoxFit.cover,
      );
    } else if (provider.pickedImage != null) {
      content = Image.memory(
        provider.pickedImage!.readAsBytesSync(),
        fit: BoxFit.cover,
      );
    } else {
      content = Container(
        color: Colors.blue[100],
        alignment: Alignment.center,
        child: ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
            stops: const [0.0, 1.0],
            colors: [Colors.red[700]!, Colors.blue[700]!],
          ).createShader(bounds),
          child: const Icon(
            CustomIcons.pilot,
            size: size * 0.7,
            color: Colors.white,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 4.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 14.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(child: content),
    );
  }
}

/// Tappable card for choosing a photo source (Galerie / Appareil photo).
/// Uses the same [CustomDecorations.cardLight] as the rest of the app
/// (translucent blue tint + white border) so it blends with the
/// gradient background. Visual differentiation between the two cards
/// is carried by the icon halo and the label colour.
class _SourceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SourceCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
          decoration: CustomDecorations.cardLight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.18),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.20),
                      blurRadius: 8.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 28.0),
              ),
              const SizedBox(height: 10.0),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
