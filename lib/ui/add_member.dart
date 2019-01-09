import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/services/members_service.dart';
import 'package:chachatte_team/utils/date_utils.dart';
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

class _AddMemberState extends State<AddMember> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _controller = new TextEditingController();

  // the Member to be created
  final Member newMember = new Member();

  /// Initialize and display a Date picker related to the specified [controller] in the specified [context]
  Future _chooseDate(BuildContext context, TextEditingController controller, DateTime defaultValue) async {
    final DateTime currentDate = DateTime.now();
    final TimeOfDay currentTime = TimeOfDay.now();

    // define initial date and time from the specified default DateTime value
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
      controller.text = DateFormat("dd/MM/yyyy HH:mm").format(finalDateTime);
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
        membersService.updateMember(member);
        // go back with a message, the result is awaited in caller
        Navigator.pop(context, AppString.memberUpdated);
      } else {
        membersService.createMember(member);
        // go back with a message, the result is awaited in caller
        Navigator.pop(context, AppString.memberCreated);
      }
    }
  }

  bool isValidPhoneNumber(String input) {
    final RegExp regex = new RegExp(r'^\(\d\d\d\)\d\d\d\-\d\d\d\d$');
    return regex.hasMatch(input);
  }

  bool isValidEmail(String input) {
    final RegExp regex = new RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    return regex.hasMatch(input);
  }

  /// Go back to previous page
  void goBack() {
    Navigator.pop(context);
  }

  Widget build(BuildContext context) {
    // the current Member to be edited
    final Member currMember = widget.member != null ? widget.member : newMember;

    // set controller text
    _controller.text = DateUtils.convertToString(currMember.registrationDate, "dd/MM/yyyy HH:mm");

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
                    onPressed: goBack,
                  )),
                  new Expanded(
                      child: new FlatButton(
                    child: Text(AppString.save.toUpperCase()),
                    onPressed: () => submitForm(currMember),
                  )),
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
                  autovalidate: true,
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
                        validator: (val) => val.isEmpty ? AppString.memberEmailMandatory : (isValidEmail(val) ? null : AppString.memberEmailNotValid),
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
                        inputFormatters: [new LengthLimitingTextInputFormatter(16)],
                        validator: (val) => val.isEmpty ? AppString.memberPhoneMandatory : (isValidPhoneNumber(val) ? null : AppString.memberPhoneNotValid),
                        onSaved: (val) => currMember.phone = val,
                        initialValue: currMember.phone,
                      ),
                      new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.motorcycle),
                          hintText: AppString.memberBikeHint,
                          labelText: AppString.memberBike,
                        ),
                        maxLines: 1,
                        inputFormatters: [new LengthLimitingTextInputFormatter(64), new WhitelistingTextInputFormatter(new RegExp(r'^[()\d -]{1,15}$'))],
                        validator: (val) => val.isEmpty ? AppString.memberBikeMandatory : null,
                        onSaved: (val) => currMember.bike = val,
                        initialValue: currMember.bike,
                      ),
                      new GestureDetector(
                          onTap: () => _chooseDate(context, _controller, currMember.registrationDate),
                          child: AbsorbPointer(
                              child: new TextFormField(
                            decoration: new InputDecoration(
                              icon: const Icon(Icons.calendar_today),
                              hintText: AppString.memberRegistrationDateHint,
                              labelText: AppString.memberRegistrationDate,
                            ),
                            controller: _controller,
                            keyboardType: TextInputType.datetime,
                            validator: (val) => DateUtils.isBeforeNow(val, "dd/MM/yyyy HH:mm")
                                ? (val.isEmpty ? AppString.memberRegistrationDateMandatory : null)
                                : AppString.memberRegistrationDateNotValid,
                            onSaved: (val) => currMember.registrationDate = new DateFormat("dd/MM/yyyy HH:mm").parseStrict(val),
                          ))),
                    ],
                  ))),
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [Colors.green[300], Colors.blue[300]],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(0.0, 1.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
        ));
  }
}
