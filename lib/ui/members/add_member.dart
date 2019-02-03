import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/services/members_service.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:chachatte_team/utils/string_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddMember extends StatefulWidget {
  final Member member;

  const AddMember({Key key, this.member}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddMemberState();
  }
}

/// Input formatter class for E.164 phone number
class NumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = new StringBuffer();
    // add a "+" in front of the text
    if (newTextLength >= 1) {
      newText.write('+');
      if (newValue.selection.end >= 1) selectionIndex++;
    }
    // add a space after the 3rd character
    if (newTextLength >= 3) {
      newText.write(newValue.text.substring(0, usedSubstringIndex = 2) + ' ');
      if (newValue.selection.end >= 2) selectionIndex += 1;
    }
    // then write following characters
    if (newTextLength >= usedSubstringIndex) newText.write(newValue.text.substring(usedSubstringIndex));
    return new TextEditingValue(
      text: newText.toString(),
      selection: new TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

class _AddMemberState extends State<AddMember> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _datePickerController = new TextEditingController();

  // the Member to be created
  final Member _newMember = new Member();

  initState() {
    // set date picker text if set
    if (widget.member != null) {
      _datePickerController.text = DateUtils.convertToString(widget.member.registrationDate, AppConstants.DATE_FORMAT);
    }
    return super.initState();
  }

  /// Initialize and display a Date picker related to the specified [controller] in the specified [context]
  Future _chooseDate(BuildContext context, TextEditingController controller, DateTime defaultValue) async {
    final DateTime currentDate = DateTime.now();
    final TimeOfDay currentTime = TimeOfDay.now();

    // define initial date and time from the specified default DateTime value if set
    final DateTime initialDate = defaultValue ?? currentDate;
    final TimeOfDay initialTime = defaultValue != null ? TimeOfDay.fromDateTime(defaultValue) : currentTime;

    // show the date picker and await for the chosen date
    final DateTime dateResult =
        await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(currentDate.year - 5), lastDate: DateTime(currentDate.year + 5));
    if (dateResult == null) return;

    // show the time picker and await for the chosen time
    final TimeOfDay timeResult = await showTimePicker(context: context, initialTime: initialTime);
    if (timeResult == null) return;

    // build final date with time
    final DateTime finalDateTime = DateTime(dateResult.year, dateResult.month, dateResult.day, timeResult.hour, timeResult.minute);

    // notify the framework that the internal state of this object has changed
    setState(() {
      controller.text = DateFormat(AppConstants.DATE_FORMAT).format(finalDateTime);
    });
  }

  /// Validate the form then submit data to backend
  void submitForm(Member member) {
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(backgroundColor: Colors.red, content: new Text(AppString.formNotValid)));
    } else {
      // this invokes each onSaved event
      form.save();

      var membersService = new MembersService();

      // submit data to backend, if id is set this is an update, else a creation
      if (member.id != null) {
        // update the news go back with a message, the result is awaited in caller
        membersService.updateMember(member).then((value) {
          Navigator.pop(context, AppString.memberUpdated);
        }, onError: (error) {
          Navigator.pop(context, AppString.memberUpdateFailed);
        });
      } else {
        // create the news go back with a message, the result is awaited in caller
        membersService.createMember(member).then((value) {
          Navigator.pop(context, AppString.memberCreated);
        }, onError: (error) {
          Navigator.pop(context, AppString.memberCreationFailed);
        });
      }
    }
  }

  Widget build(BuildContext context) {
    // the current Member to be edited
    final Member currMember = widget.member != null ? widget.member : _newMember;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppString.createMember),
        bottom: PreferredSize(
          child: Container(
            child: Row(
              children: <Widget>[
                new Expanded(
                  child: new FlatButton(
                    child: Text(AppString.cancel.toUpperCase()),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                new Expanded(
                  child: new FlatButton(
                    child: Text(AppString.save.toUpperCase()),
                    onPressed: () => submitForm(currMember),
                  ),
                ),
              ],
            ),
            decoration: new BoxDecoration(color: Colors.green[400]),
            height: 50.0,
          ),
          preferredSize: Size.fromHeight(50.0),
        ),
      ),
      body: Container(
        child: new SafeArea(
          top: false,
          bottom: false,
          child: new Form(
            key: _formKey,
            autovalidate: false,
            child: new ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                new TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.person),
                    hintText: AppString.memberFirstNameHint,
                    labelText: AppString.memberFirstName,
                  ),
                  maxLines: 1,
                  inputFormatters: [new LengthLimitingTextInputFormatter(64)],
                  validator: (val) => val.isEmpty ? AppString.memberFirstNameMandatory : null,
                  onSaved: (val) => currMember.firstName = val,
                  initialValue: currMember.firstName,
                ),
                new TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.person),
                    hintText: AppString.memberLastNameHint,
                    labelText: AppString.memberLastName,
                  ),
                  maxLines: 1,
                  inputFormatters: [new LengthLimitingTextInputFormatter(64)],
                  validator: (val) => val.isEmpty ? AppString.memberLastNameMandatory : null,
                  onSaved: (val) => currMember.lastName = val,
                  initialValue: currMember.lastName,
                ),
                new TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.mail),
                    hintText: AppString.memberEmailHint,
                    labelText: AppString.memberEmail,
                  ),
                  maxLines: 1,
                  inputFormatters: [new LengthLimitingTextInputFormatter(128)],
                  validator: (val) => val.isEmpty ? AppString.memberEmailMandatory : (StringUtils.isValidEmail(val) ? null : AppString.memberEmailNotValid),
                  onSaved: (val) => currMember.email = val,
                  initialValue: currMember.email,
                ),
                new TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.phone),
                    hintText: AppString.memberPhoneHint,
                    labelText: AppString.memberPhone,
                  ),
                  maxLines: 1,
                  inputFormatters: <TextInputFormatter>[new LengthLimitingTextInputFormatter(13), WhitelistingTextInputFormatter.digitsOnly, NumberTextInputFormatter()],
                  validator: (val) => val.isEmpty ? AppString.memberPhoneMandatory : (StringUtils.isValidPhoneNumber(val) ? null : AppString.memberPhoneNotValid),
                  onSaved: (val) => currMember.phone = val,
                  initialValue: currMember.phone,
                ),
                new TextFormField(
                  decoration: const InputDecoration(icon: const Icon(Icons.motorcycle), hintText: AppString.memberBikeHint, labelText: AppString.memberBike),
                  maxLines: 1,
                  inputFormatters: [new LengthLimitingTextInputFormatter(64)],
                  validator: (val) => val.isEmpty ? AppString.memberBikeMandatory : null,
                  onSaved: (val) => currMember.bike = val,
                  initialValue: currMember.bike,
                ),
                new GestureDetector(
                  onTap: () => _chooseDate(context, _datePickerController, currMember.registrationDate),
                  child: AbsorbPointer(
                    child: new TextFormField(
                      decoration: new InputDecoration(
                        icon: const Icon(Icons.calendar_today),
                        hintText: AppString.memberRegistrationDateHint,
                        labelText: AppString.memberRegistrationDate,
                      ),
                      controller: _datePickerController,
                      keyboardType: TextInputType.datetime,
                      validator: (val) => DateUtils.isBeforeNow(val, AppConstants.DATE_FORMAT)
                          ? (val.isEmpty ? AppString.memberRegistrationDateMandatory : null)
                          : AppString.memberRegistrationDateNotValid,
                      onSaved: (val) => currMember.registrationDate = new DateFormat(AppConstants.DATE_FORMAT).parseStrict(val),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [Colors.green[300], Colors.blue[300]],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
      ),
    );
  }
}
