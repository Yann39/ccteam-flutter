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
import 'dart:typed_data';

import 'package:ccteam/providers/avatar_provider.dart';
import 'package:ccteam/providers/member_creation_provider.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

/// Internal state of the avatar editor: what the user has staged but
/// not yet confirmed.
enum _PendingChange {
  /// no in-progress change — the preview shows the saved avatar
  none,

  /// user picked & cropped a new photo (held in AvatarProvider) — the
  /// preview shows the new cropped image
  newImage,

  /// user explicitly chose to remove the existing avatar — the preview
  /// shows the default placeholder
  removal,
}

class EditAvatar extends StatefulWidget {
  const EditAvatar({Key? key}) : super(key: key);

  @override
  State<EditAvatar> createState() => _EditAvatarState();
}

class _EditAvatarState extends State<EditAvatar> {
  /// Snapshot of the avatar at page entry. Used as the "before" reference
  /// to revert to when the user taps "Annuler la sélection", and to
  /// decide whether the "Retirer la photo" affordance should be shown.
  String? _originalAvatar;

  /// What the user has staged but not yet confirmed.
  _PendingChange _pendingChange = _PendingChange.none;

  @override
  void initState() {
    super.initState();
    // Capture the original avatar from the in-progress edit copy so we
    // can revert to it on cancel and decide whether removal is offered.
    final memberCreationProvider = Provider.of<MemberCreationProvider>(context, listen: false);
    _originalAvatar = memberCreationProvider.currentMember.avatar;
  }

  /// Pick an image from the gallery, crop it, and stage it as the new
  /// pending avatar. Sets [_pendingChange] to [_PendingChange.newImage]
  /// only if the user actually completes the crop step.
  Future _selectImageFromGallery() async {
    final avatarProvider = Provider.of<AvatarProvider>(context, listen: false);
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 768,
      maxHeight: 768,
      imageQuality: 60,
    );
    if (image != null) {
      avatarProvider.setPickedImage(File(image.path));
      avatarProvider.setPickedImageName(image.name);
      // ensure we don't carry over a stale cropped image from a
      // previous pick — if the user backs out of ImageCrop without
      // cropping, the pending state must NOT flip to newImage
      avatarProvider.setCroppedImage(null);
      await Navigator.of(context).pushNamed('/imageCrop');
      if (avatarProvider.croppedImage != null) {
        setState(() => _pendingChange = _PendingChange.newImage);
      }
    }
  }

  /// Pick an image from the camera, crop it, and stage it as the new
  /// pending avatar. Same flow as [_selectImageFromGallery] but with
  /// the camera as the source.
  Future _selectImageFromCamera() async {
    final avatarProvider = Provider.of<AvatarProvider>(context, listen: false);
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 768,
      maxHeight: 768,
      imageQuality: 60,
    );
    if (image != null) {
      avatarProvider.setPickedImage(File(image.path));
      avatarProvider.setPickedImageName(image.name);
      avatarProvider.setCroppedImage(null);
      await Navigator.of(context).pushNamed('/imageCrop');
      if (avatarProvider.croppedImage != null) {
        setState(() => _pendingChange = _PendingChange.newImage);
      }
    }
  }

  /// Discard the pending change — the preview snaps back to the saved
  /// avatar that was on screen when the page opened.
  void _cancelPendingChange() {
    final avatarProvider = Provider.of<AvatarProvider>(context, listen: false);
    avatarProvider.setPickedImage(null);
    avatarProvider.setPickedImageName(null);
    avatarProvider.setCroppedImage(null);
    setState(() => _pendingChange = _PendingChange.none);
  }

  /// Stage avatar removal — the preview switches to the default
  /// placeholder; the change is only persisted to the edit copy when
  /// the user taps "Confirmer la sélection".
  void _stageAvatarRemoval() {
    final avatarProvider = Provider.of<AvatarProvider>(context, listen: false);
    avatarProvider.setPickedImage(null);
    avatarProvider.setPickedImageName(null);
    avatarProvider.setCroppedImage(null);
    setState(() => _pendingChange = _PendingChange.removal);
  }

  /// Commit the pending change to the in-progress edit copy
  /// (MemberCreationProvider.currentMember). The drawer and the rest
  /// of the app are NOT updated yet — that happens when the user
  /// presses "Save" on the profile form.
  void _confirm() {
    final avatarProvider = Provider.of<AvatarProvider>(context, listen: false);
    final memberCreationProvider = Provider.of<MemberCreationProvider>(context, listen: false);
    if (_pendingChange == _PendingChange.newImage && avatarProvider.croppedImage != null) {
      memberCreationProvider.setCurrentMemberAvatar(
        base64Encode(avatarProvider.croppedImage!),
        avatarProvider.pickedImageName,
      );
    } else if (_pendingChange == _PendingChange.removal) {
      memberCreationProvider.setCurrentMemberAvatar(null, null);
    }
    Navigator.pop(context);
  }

  /// Compact subtitle ("Max. 500 Ko · JPG, GIF, PNG") — strips the
  /// leading "Formats " prefix so the line stays on a single row.
  String _formatsShort() {
    final String formats = AppString.avatarFormats;
    return formats.startsWith("Formats ") ? formats.substring("Formats ".length) : formats;
  }

  @override
  Widget build(BuildContext context) {
    final avatarProvider = Provider.of<AvatarProvider>(context, listen: true);

    final bool hasOriginal = _originalAvatar != null;
    final bool hasPendingChange = _pendingChange != _PendingChange.none;

    return Scaffold(
      appBar: AppBar(title: Text(AppString.profilePhoto)),
      body: Container(
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
                  child: _AvatarPreview(
                    pendingChange: _pendingChange,
                    croppedImage: avatarProvider.croppedImage,
                    originalAvatar: _originalAvatar,
                  ),
                ),
                const SizedBox(height: 24.0),

                // Heading + constraints (one compact line)
                Text(
                  AppString.selectPhoto,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black.withAlpha(204)),
                ),
                const SizedBox(height: 4.0),
                Text(
                  "${AppString.maxAvatarSize} · ${_formatsShort()}",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: Colors.black.withAlpha(140)),
                ),
                const SizedBox(height: 24.0),

                Row(
                  children: <Widget>[
                    Expanded(
                      child: _SourceCard(
                        icon: Icons.photo_library_rounded,
                        label: AppString.gallery,
                        color: Colors.blue[700]!,
                        onTap: _selectImageFromGallery,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: _SourceCard(
                        icon: Icons.photo_camera_rounded,
                        label: AppString.camera,
                        color: Colors.deepPurple[600]!,
                        onTap: _selectImageFromCamera,
                      ),
                    ),
                  ],
                ),

                if (hasOriginal && !hasPendingChange) ...[
                  const SizedBox(height: 12.0),
                  Center(
                    child: TextButton.icon(
                      onPressed: _stageAvatarRemoval,
                      icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[700]),
                      label: Text(
                        AppString.removePhoto,
                        style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],

                if (hasPendingChange) ...[
                  const SizedBox(height: 12.0),
                  Center(
                    child: TextButton.icon(
                      onPressed: _cancelPendingChange,
                      icon: Icon(Icons.close, size: 18, color: Colors.black.withAlpha(160)),
                      label: Text(
                        AppString.cancelSelection,
                        style: TextStyle(color: Colors.black.withAlpha(180), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ElevatedButton.icon(
                    onPressed: _confirm,
                    icon: const Icon(Icons.check, size: 18, color: Colors.white),
                    label: Text(AppString.confirmSelection, style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                      elevation: 1,
                    ),
                  ),
                ] else
                  const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular avatar preview at the top of the page. Shown content
/// depends on the editor's pending state:
///   - newImage  → the freshly cropped image
///   - removal   → the default pilot placeholder
///   - none      → the saved avatar (or default if none was saved)
class _AvatarPreview extends StatelessWidget {
  final _PendingChange pendingChange;
  final Uint8List? croppedImage;
  final String? originalAvatar;

  const _AvatarPreview({
    Key? key,
    required this.pendingChange,
    required this.croppedImage,
    required this.originalAvatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double size = 200.0;

    Widget content;
    if (pendingChange == _PendingChange.newImage && croppedImage != null) {
      content = Image.memory(croppedImage!, fit: BoxFit.cover);
    } else if (pendingChange == _PendingChange.none && originalAvatar != null) {
      content = Image.memory(base64Decode(originalAvatar!), fit: BoxFit.cover);
    } else {
      // pendingChange == removal, OR pendingChange == none with no
      // original avatar — show the default pilot placeholder
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
          child: const Icon(CustomIcons.pilot, size: size * 0.7, color: Colors.white),
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 14.0, offset: const Offset(0, 4)),
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

  const _SourceCard({Key? key, required this.icon, required this.label, required this.color, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
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
                    BoxShadow(color: color.withValues(alpha: 0.20), blurRadius: 8.0, offset: const Offset(0, 2)),
                  ],
                ),
                child: Icon(icon, color: color, size: 28.0),
              ),
              const SizedBox(height: 10.0),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14.0),
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
