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

import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/loading_content.dart';
import 'package:ccteam/widgets/save_cancel_bar.dart';
import 'package:flutter/material.dart';

/// Standard scaffold for every "add / edit" form in the authenticated
/// part of the app. Encapsulates the chrome that every form repeats —
/// AppBar with an optional delete action, the blue gradient background,
/// the LoadingContent wrapper, and the bottom SaveCancelBar pinned to
/// the safe area — so the screens only have to declare their fields.
///
/// Fields are passed as a list and laid out vertically in a scrollable
/// [ListView.separated] with a constant [UI_FORM_FIELD_SPACING] gap
/// between each. Padding is uniform: [UI_FORM_PADDING] horizontally
/// and 16 px vertically.
///
/// The caller keeps ownership of the [Form] key and the submit logic
/// (validate / save / call the provider). [onSave] is wired to the
/// SaveCancelBar's confirm button; [onCancel] defaults to popping the
/// current route. Set [onDelete] to surface a trash icon in the AppBar
/// (typically only when editing an existing entity).
///
/// [loadingStatus] is forwarded to [LoadingContent] so screens that
/// asynchronously prepare data can show a spinner instead of the form
/// until the data is ready. Defaults to [LoadingStatus.loaded] for
/// screens that have nothing to load.
///
/// [header] is rendered edge-to-edge above the field list, outside the
/// form's horizontal padding. Use it for full-width visual elements
/// such as a banner, hero image, or a member avatar straddling a
/// coloured strip — anything that should not be indented like a form
/// field. The header sits inside the same scrollable area, so it
/// scrolls with the fields when the keyboard opens.
class FormScaffold extends StatelessWidget {
  const FormScaffold({
    Key? key,
    required this.title,
    required this.formKey,
    required this.fields,
    required this.onSave,
    this.onCancel,
    this.onDelete,
    this.loadingStatus = LoadingStatus.loaded,
    this.header,
  }) : super(key: key);

  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> fields;
  final VoidCallback onSave;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final LoadingStatus loadingStatus;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final List<Widget> appBarActions = <Widget>[
      if (onDelete != null) IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
    ];

    final Widget formBody = header == null
        ? ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: UI_FORM_PADDING, vertical: 16.0),
            itemCount: fields.length,
            itemBuilder: (context, index) => fields[index],
            separatorBuilder: (context, index) => const SizedBox(height: UI_FORM_FIELD_SPACING),
          )
        : CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(child: header),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: UI_FORM_PADDING, vertical: 16.0),
                sliver: SliverList.separated(
                  itemCount: fields.length,
                  itemBuilder: (context, index) => fields[index],
                  separatorBuilder: (context, index) => const SizedBox(height: UI_FORM_FIELD_SPACING),
                ),
              ),
            ],
          );

    return Scaffold(
      appBar: AppBar(title: Text(title), actions: appBarActions.isEmpty ? null : appBarActions),
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: LoadingContent(
          loadingStatus: loadingStatus,
          defaultText: AppString.contentNotLoaded,
          emptyText: AppString.noContentToDisplay,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Form(key: formKey, child: formBody),
              ),
              SafeArea(
                child: SaveCancelBar(saveFunction: onSave, cancelFunction: onCancel ?? () => Navigator.pop(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
