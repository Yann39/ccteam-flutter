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

import 'package:ccteam/models/photo.dart';
import 'package:ccteam/services/photos_service.dart';
import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/save_cancel_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/photo_creation_provider.dart';

class AddEditPhoto extends StatefulWidget {
  const AddEditPhoto({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddEditPhotoState();
  }
}

class _AddEditPhotoState extends State<AddEditPhoto> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // the Photo to be created
  final Photo _newPhoto = new Photo();

  /// Validate the form then submit data to backend
  void submitForm(Photo photo) {
    final FormState form = _formKey.currentState!;

    if (!form.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(AppString.formNotValid),
        ),
      );
    } else {
      // this invokes each onSaved photo
      form.save();

      var photosService = new PhotosService();

      // submit data to backend, if id is set this is an update, else a creation
      if (photo.id != null) {
        // update the photo and go back with a message, the result is awaited in caller
        photosService
            .updatePhoto(photo)
            .then(
              (value) {
                Navigator.pop(context, AppString.photoUpdated);
              },
              onError: (error) {
                Navigator.pop(context, AppString.photoUpdateFailed);
              },
            );
      } else {
        // create the photo and go back with a message, the result is awaited in caller
        photosService
            .createPhoto(photo)
            .then(
              (value) {
                Navigator.pop(context, AppString.photoCreated);
              },
              onError: (error) {
                Navigator.pop(context, AppString.photoCreationFailed);
              },
            );
      }
    }
  }

  Widget build(BuildContext context) {
    final _photoCreationProvider = Provider.of<PhotoCreationProvider>(
      context,
      listen: true,
    );
    // the current Photo to be edited
    final Photo _currPhoto =
        _photoCreationProvider.photo.id != null
            ? _photoCreationProvider.photo
            : _newPhoto;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(AppString.photoCreate)),
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: Stack(
          children: <Widget>[
            Form(
              autovalidateMode: AutovalidateMode.disabled,
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: UI_FORM_PADDING),
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.title),
                      hintText: AppString.photoTitleHint,
                      labelText: AppString.photoTitle,
                    ),
                    maxLines: 1,
                    inputFormatters: [LengthLimitingTextInputFormatter(128)],
                    validator:
                        (val) =>
                            (val == null || val.isEmpty)
                                ? AppString.photoTitleMandatory
                                : null,
                    onSaved: (val) => _currPhoto.title = val,
                    initialValue: _currPhoto.title,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.description),
                      hintText: AppString.photoDescriptionHint,
                      labelText: AppString.photoDescription,
                    ),
                    maxLines: 1,
                    inputFormatters: [LengthLimitingTextInputFormatter(2048)],
                    validator:
                        (val) =>
                            (val == null || val.isEmpty)
                                ? AppString.photoDescriptionMandatory
                                : null,
                    onSaved: (val) => _currPhoto.description = val,
                    initialValue: _currPhoto.description,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.link),
                      hintText: AppString.photoLinkHint,
                      labelText: AppString.photoLink,
                    ),
                    maxLines: 1,
                    inputFormatters: [LengthLimitingTextInputFormatter(2048)],
                    validator:
                        (val) =>
                            (val == null || val.isEmpty)
                                ? AppString.photoLinkMandatory
                                : null,
                    onSaved: (val) => _currPhoto.link = val,
                    initialValue: _currPhoto.link,
                  ),
                ],
              ),
            ),
            Positioned(
              height: 50,
              bottom: 0,
              left: 0,
              right: 0,
              child: SaveCancelBar(
                saveFunction: () => submitForm(_currPhoto),
                cancelFunction: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
