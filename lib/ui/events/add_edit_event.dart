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

import 'package:ccteam/models/event.dart';
import 'package:ccteam/models/organizer.dart';
import 'package:ccteam/models/track.dart';
import 'package:ccteam/providers/event_creation_provider.dart';
import 'package:ccteam/providers/event_detail_provider.dart';
import 'package:ccteam/providers/event_list_provider.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/providers/organizer_list_provider.dart';
import 'package:ccteam/services/tracks_service.dart';
import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/track_utils.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/string_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/form_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddEditEvent extends StatefulWidget {
  const AddEditEvent({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddEditEventState();
  }
}

class _AddEditEventState extends State<AddEditEvent> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final TextEditingController _startDatePickerController = new TextEditingController();
  final TextEditingController _endDatePickerController = new TextEditingController();
  final TracksService _tracksService = new TracksService();

  Future<List<Track>>? _futureTracks;
  Track? _selectedTrack;

  Organizer? _selectedOrganizer;

  /// Bumped to force the organizer dropdown to re-seed its displayed value:
  /// after picking the "add organizer" entry (to drop the sentinel) or after a
  /// new organizer is created (to select it).
  int _organizerFieldEpoch = 0;

  /// Sentinel value for the "add new organizer" entry appended to the dropdown
  /// (identified by its id == -1).
  static final Organizer _addOrganizerSentinel = Organizer(id: -1);

  /// Prime the organizer list once, after the State is attached to the
  /// tree (initState can't safely call providers that need a context
  /// hop). The provider keeps the list cached, so reopening the form
  /// later doesn't re-fetch.
  bool _organizersBootstrapped = false;

  initState() {
    final EventCreationProvider _eventCreationProvider = Provider.of<EventCreationProvider>(context, listen: false);
    // fetch the tracks in initState so it is not fetch each time the state change
    _futureTracks = _tracksService.fetchTracks();
    _selectedOrganizer = _eventCreationProvider.event.organizer;
    // set date picker text
    _startDatePickerController.text = AppDateUtils.convertToString(
      _eventCreationProvider.event.startDate != null ? _eventCreationProvider.event.startDate! : DateTime.now(),
      DATE_FORMAT,
    )!;
    _endDatePickerController.text = AppDateUtils.convertToString(
      _eventCreationProvider.event.startDate != null
          ? _eventCreationProvider.event.endDate!
          : DateTime.now().add(Duration(days: 1)),
      DATE_FORMAT,
    )!;
    return super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_organizersBootstrapped) return;
    _organizersBootstrapped = true;
    // kick off the organizer fetch the first time the page is built.
    // The provider's `ensureLoaded` is a no-op when already cached.
    final OrganizerListProvider organizerListProvider = Provider.of<OrganizerListProvider>(context, listen: false);
    organizerListProvider.ensureLoaded();
  }

  /// Prompt for a name and create a new organizer via [provider], then select it
  /// in the dropdown. Reached from the "Ajouter un organisateur…" entry (admins only).
  Future<void> _openAddOrganizerDialog(OrganizerListProvider provider) async {
    // revert the dropdown from the "add" sentinel back to the current selection
    setState(() => _organizerFieldEpoch++);

    // the dialog owns its own TextEditingController (disposed in its State) so we
    // never dispose a controller while its TextField is still animating out
    final String? name = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => const _AddOrganizerDialog(),
    );

    if (name == null || name.isEmpty) return;
    final Organizer? created = await provider.createOrganizer(name);
    if (!mounted || created == null) return;
    setState(() {
      _selectedOrganizer = created;
      _organizerFieldEpoch++;
    });
  }

  /// Initialize and display a Date picker related to the specified [controller] in the specified [context]
  Future _chooseDate(BuildContext context, TextEditingController controller, DateTime? defaultValue) async {
    final DateTime currentDate = DateTime.now();
    final TimeOfDay currentTime = TimeOfDay.now();

    // define initial date and time from the specified default DateTime value if set
    final DateTime initialDate = defaultValue ?? currentDate;
    final TimeOfDay initialTime = defaultValue != null ? TimeOfDay.fromDateTime(defaultValue) : currentTime;

    // show the date picker and await for the chosen date
    final DateTime? dateResult = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (dateResult == null) return;

    // show the time picker and await for the chosen time
    final TimeOfDay? timeResult = await showTimePicker(context: context, initialTime: initialTime);
    if (timeResult == null) return;

    // build final date with time
    final DateTime finalDateTime = DateTime(
      dateResult.year,
      dateResult.month,
      dateResult.day,
      timeResult.hour,
      timeResult.minute,
    );

    // notify the framework that the internal state of this object has changed
    setState(() {
      controller.text = DateFormat(DATE_FORMAT).format(finalDateTime);
    });
  }

  /// Validate the form then submit data to backend
  void submitForm(Event event) {
    final FormState _form = _formKey.currentState!;

    if (!_form.validate()) {
      Provider.of<MessageProvider>(context, listen: false).setMessage(AppString.formNotValid, MessageType.ERROR);
    } else {
      // this invokes each onSaved event
      _form.save();

      final EventCreationProvider _eventCreationProvider = Provider.of<EventCreationProvider>(context, listen: false);
      final EventListProvider _eventListProvider = Provider.of<EventListProvider>(context, listen: false);
      final EventDetailProvider _eventDetailProvider = Provider.of<EventDetailProvider>(context, listen: false);
      final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);

      // submit data to backend, if id is set this is an update, else a creation
      if (event.id != null) {
        event.modifiedBy = _loginProvider.loggedMember;
        _eventCreationProvider.updateEvent().then((value) {
          // update event in related UIs
          _eventListProvider.updateEventInList(_eventCreationProvider.event);
          _eventDetailProvider.setCurrentEvent(_eventCreationProvider.event);
        });
      } else {
        event.createdBy = _loginProvider.loggedMember;
        _eventCreationProvider.createEvent().then((value) {
          _eventListProvider.addEventInList(_eventCreationProvider.event);
        });
      }
      Navigator.pop(context);
    }
  }

  Widget build(BuildContext context) {
    final _eventCreationProvider = Provider.of<EventCreationProvider>(context, listen: true);

    final _titleField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.title),
        hintText: AppString.eventTitleHint,
        labelText: AppString.eventTitle,
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(128)],
      validator: (val) => (val == null || val.isEmpty) ? AppString.eventTitleMandatory : null,
      onSaved: (val) => _eventCreationProvider.event.title = val!,
      initialValue: _eventCreationProvider.event.title,
    );

    final _descriptionField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.description),
        hintText: AppString.eventDescriptionHint,
        labelText: AppString.eventDescription,
      ),
      maxLines: 2,
      inputFormatters: [LengthLimitingTextInputFormatter(2048)],
      validator: (val) => (val == null || val.isEmpty) ? AppString.eventDescriptionMandatory : null,
      onSaved: (val) => _eventCreationProvider.event.description = val,
      initialValue: _eventCreationProvider.event.description,
    );

    final _priceField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.attach_money),
        hintText: AppString.eventPriceHint,
        labelText: AppString.eventPrice,
      ),
      maxLines: 1,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
      inputFormatters: [LengthLimitingTextInputFormatter(7)],
      validator: (val) {
        if (val == null || val.isEmpty) return AppString.eventPriceMandatory;
        if (!StringUtils.isValidPrice(val)) return AppString.eventPriceNotValid;
        return null;
      },
      onSaved: (val) => _eventCreationProvider.event.price = double.parse(val!),
      initialValue: _eventCreationProvider.event.price != null
          ? StringUtils.formatPrice(_eventCreationProvider.event.price!)
          : "",
    );

    final _trackField = FutureBuilder<List<Track>>(
      future: _futureTracks,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return DropdownButtonFormField<Track>(
            initialValue: _selectedTrack != null
                ? _selectedTrack
                : _eventCreationProvider.event.id != null
                ? snapshot.data!.firstWhere(
                    (Track t) => t.id == _eventCreationProvider.event.track!.id,
                    orElse: () => snapshot.data!.first,
                  )
                : snapshot.data!.isNotEmpty
                ? snapshot.data!.first
                : null,
            decoration: const InputDecoration(
              icon: Icon(CustomIcons.track),
              hintText: AppString.eventTrackIdHint,
              labelText: AppString.eventTrackId,
            ),
            isExpanded: true,
            items: snapshot.data!.map((Track val) {
              return DropdownMenuItem<Track>(
                value: val,
                child: Row(
                  children: <Widget>[
                    Icon(TrackUtils.iconForTrack(val), size: 20.0, color: Colors.red[600]),
                    const SizedBox(width: 8.0),
                    Flexible(child: Text(val.name ?? '', overflow: TextOverflow.ellipsis)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (Track? val) => setState(() => _selectedTrack = val),
            onSaved: (val) => _eventCreationProvider.event.track = val,
            validator: (val) => val == null ? AppString.eventTrackIdMandatory : null,
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return const CircularProgressIndicator();
      },
    );

    final _organizerField = Consumer<OrganizerListProvider>(
      builder: (_, organizerListProvider, __) {
        if (organizerListProvider.loadingStatus == LoadingStatus.loading && organizerListProvider.organizers.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final bool isAdmin = Provider.of<LoginProvider>(context, listen: false).isAdmin;
        final List<Organizer> options = organizerListProvider.organizers;
        final Organizer? currentValue = _selectedOrganizer == null
            ? null
            : options.firstWhere((o) => o.id == _selectedOrganizer!.id, orElse: () => _selectedOrganizer!);
        return DropdownButtonFormField<Organizer>(
          // re-seed the displayed value after the "add organizer" sentinel is picked or a new one is created
          key: ValueKey<int>(_organizerFieldEpoch),
          initialValue: currentValue,
          decoration: const InputDecoration(
            icon: Icon(Icons.perm_contact_calendar),
            hintText: AppString.eventOrganizerHint,
            labelText: AppString.eventOrganizer,
          ),
          items: <DropdownMenuItem<Organizer>>[
            ...options.map((Organizer o) {
              return DropdownMenuItem<Organizer>(value: o, child: Text(o.name ?? '—'));
            }),
            // admins can create a new organizer straight from the picker
            if (isAdmin)
              DropdownMenuItem<Organizer>(
                value: _addOrganizerSentinel,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.add, size: 18.0, color: Colors.blue[700]),
                    const SizedBox(width: 6.0),
                    Text(
                      AppString.eventOrganizerAddOption,
                      style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
          ],
          onChanged: (Organizer? val) {
            if (val != null && val.id == _addOrganizerSentinel.id) {
              _openAddOrganizerDialog(organizerListProvider);
            } else {
              setState(() => _selectedOrganizer = val);
            }
          },
          onSaved: (val) => _eventCreationProvider.event.organizer = val,
          validator: (val) => val == null ? AppString.eventOrganizerMandatory : null,
        );
      },
    );

    final _startDateField = GestureDetector(
      onTap: () => _chooseDate(context, _startDatePickerController, _eventCreationProvider.event.startDate),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: const InputDecoration(
            icon: Icon(Icons.event),
            hintText: AppString.eventStartDateHint,
            labelText: AppString.eventStartDate,
          ),
          controller: _startDatePickerController,
          keyboardType: TextInputType.datetime,
          validator: (val) => (val == null || val.isEmpty) ? AppString.eventStartDateMandatory : null,
          onSaved: (val) => _eventCreationProvider.event.startDate = DateFormat(DATE_FORMAT).parseStrict(val!),
        ),
      ),
    );

    final _endDateField = GestureDetector(
      onTap: () => _chooseDate(context, _endDatePickerController, _eventCreationProvider.event.endDate),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: const InputDecoration(
            icon: Icon(Icons.event),
            hintText: AppString.eventEndDateHint,
            labelText: AppString.eventEndDate,
          ),
          controller: _endDatePickerController,
          keyboardType: TextInputType.datetime,
          validator: (val) => (val == null || val.isEmpty) ? AppString.eventEndDateMandatory : null,
          onSaved: (val) => _eventCreationProvider.event.endDate = DateFormat(DATE_FORMAT).parseStrict(val!),
        ),
      ),
    );

    return FormScaffold(
      title: AppString.eventCreate,
      formKey: _formKey,
      loadingStatus: _eventCreationProvider.loadingStatus,
      onSave: () => submitForm(_eventCreationProvider.event),
      fields: <Widget>[
        _titleField,
        _descriptionField,
        _priceField,
        _trackField,
        _organizerField,
        _startDateField,
        _endDateField,
      ],
    );
  }
}

/// Small dialog to enter a new organizer name. It owns its [TextEditingController]
/// so the framework disposes it with the dialog's element (after the exit
/// animation), instead of us disposing it early — which triggered a "dirty widget
/// in the wrong build scope" while the TextField was still animating out.
class _AddOrganizerDialog extends StatefulWidget {
  const _AddOrganizerDialog();

  @override
  State<_AddOrganizerDialog> createState() => _AddOrganizerDialogState();
}

class _AddOrganizerDialogState extends State<_AddOrganizerDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppString.eventOrganizerAddTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(hintText: AppString.eventOrganizerAddHint),
        onSubmitted: (_) => _submit(),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppString.cancel)),
        TextButton(onPressed: _submit, child: Text(AppString.eventOrganizerAddConfirm)),
      ],
    );
  }
}
