import 'package:chachatte_team/models/photo.dart';
import 'package:chachatte_team/services/photos_service.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddPhoto extends StatefulWidget {
  final Photo photo;

  const AddPhoto({Key key, this.photo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddPhotoState();
  }
}

class _AddPhotoState extends State<AddPhoto> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // the Photo to be created
  final Photo _newPhoto = new Photo();

  /// Validate the form then submit data to backend
  void submitForm(Photo photo) {
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(backgroundColor: Colors.red, content: new Text(AppString.formNotValid)));
    } else {
      // this invokes each onSaved photo
      form.save();

      var photosService = new PhotosService();

      // submit data to backend, if id is set this is an update, else a creation
      if (photo.id != null) {
        // update the photo and go back with a message, the result is awaited in caller
        photosService.updatePhoto(photo).then((value) {
          Navigator.pop(context, AppString.photoUpdated);
        }, onError: (error) {
          Navigator.pop(context, AppString.photoUpdateFailed);
        });
      } else {
        // create the photo and go back with a message, the result is awaited in caller
        photosService.createPhoto(photo).then((value) {
          Navigator.pop(context, AppString.photoCreated);
        }, onError: (error) {
          Navigator.pop(context, AppString.photoCreationFailed);
        });
      }
    }
  }

  Widget build(BuildContext context) {
    // the current Photo to be edited
    final Photo currPhoto = widget.photo != null ? widget.photo : _newPhoto;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppString.createPhoto),
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
                    onPressed: () => submitForm(currPhoto),
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
                    icon: const Icon(Icons.title),
                    hintText: AppString.photoTitleHint,
                    labelText: AppString.photoTitle,
                  ),
                  maxLines: 1,
                  inputFormatters: [new LengthLimitingTextInputFormatter(128)],
                  validator: (val) => val.isEmpty ? AppString.photoTitleMandatory : null,
                  onSaved: (val) => currPhoto.title = val,
                  initialValue: currPhoto.title,
                ),
                new TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.description),
                    hintText: AppString.photoDescriptionHint,
                    labelText: AppString.photoDescription,
                  ),
                  maxLines: 1,
                  inputFormatters: [new LengthLimitingTextInputFormatter(2048)],
                  validator: (val) => val.isEmpty ? AppString.photoDescriptionMandatory : null,
                  onSaved: (val) => currPhoto.description = val,
                  initialValue: currPhoto.description,
                ),
                new TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.link),
                    hintText: AppString.photoLinkHint,
                    labelText: AppString.photoLink,
                  ),
                  maxLines: 1,
                  inputFormatters: [new LengthLimitingTextInputFormatter(2048)],
                  validator: (val) => val.isEmpty ? AppString.photoLinkMandatory : null,
                  onSaved: (val) => currPhoto.link = val,
                  initialValue: currPhoto.link,
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
