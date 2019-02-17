import 'package:cached_network_image/cached_network_image.dart';
import 'package:chachatte_team/models/photo.dart';
import 'package:chachatte_team/services/photos_service.dart';
import 'package:chachatte_team/ui/photos/add_photo.dart';
import 'package:chachatte_team/ui/photos/photo_detail.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';

enum ConfirmDialogAction { yes, no }



class PhotoCard extends StatelessWidget {
  final Photo photo;
  final PhotosService photosService;

  PhotoCard(this.photo, this.photosService);

  /// Method that launches the photo form screen and awaits the result from Navigator.pop
  void _navigateAndDisplaySelection(BuildContext context, Photo photo) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the photo form Screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddPhoto(photo: photo)));

    // after the photo form Screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }

  /// Method that launches the Photo detail screen and awaits the result from Navigator.pop
  _navigateToPhotoDetailScreen(BuildContext context, Photo photo) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoDetail(photo: photo)));

    // after the target screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }

  void showPhoto(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(title: Text(photo.title)),
          body: SizedBox.expand(
            child: Hero(
              tag: photo.id,
              child: GridPhotoViewer(photo: photo),
            ),
          ),
        );
      }),
    );
  }

  /// Display a confirmation popup when trying to delete an photo
  void _showConfirmation(BuildContext context, String value) {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
            title: new Text(AppString.confirmation),
            content: new Text(value),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  _dialogueResult(context, ConfirmDialogAction.yes);
                },
                child: new Text(AppString.confirm),
              ),
              new FlatButton(
                onPressed: () {
                  _dialogueResult(context, ConfirmDialogAction.no);
                },
                child: new Text(AppString.cancel),
              ),
            ],
          ),
    );
  }

  /// Handle result of the photo deletion confirmation dialog
  void _dialogueResult(BuildContext context, ConfirmDialogAction value) {
    if (value == ConfirmDialogAction.yes) {
      // delete photo
      photosService.deletePhoto(photo).then((value) {
        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(AppString.photoDeleted)));
      }, onError: (error) {
        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(AppString.photoDeletionFailed)));
      });
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(
        vertical: 4.0,
        horizontal: 4.0,
      ),
      child: InkWell(
        onTap: () => /*showPhoto(context),*/ _navigateToPhotoDetailScreen(context, photo),
        child: Hero(
          flightShuttleBuilder: (
            BuildContext flightContext,
            Animation<double> animation,
            HeroFlightDirection flightDirection,
            BuildContext fromHeroContext,
            BuildContext toHeroContext,
          ) {
            final Hero toHero = toHeroContext.widget;
            return RotationTransition(
              turns: animation,
              child: toHero.child,
            );
          },
          tag: photo.id,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                placeholder: CircularProgressIndicator(),
                imageUrl: photo.link,
                fit: BoxFit.fitWidth,
              ),
              new Align(
                alignment: FractionalOffset.bottomCenter,
                child: Container(
                  height: 20.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.rectangle, color: Colors.black.withOpacity(0.5)),
                  child: Text(
                    photo.title,
                    softWrap: false,
                    style: new TextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
