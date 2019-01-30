import 'package:chachatte_team/models/photo.dart';
import 'package:chachatte_team/services/photos_service.dart';
import 'package:chachatte_team/ui/photos/add_photo.dart';
import 'package:chachatte_team/ui/photos/photo_card.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';

class Gallery extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GalleryState();
  }
}

class _GalleryState extends State<Gallery> {
  static final PhotosService photosService = new PhotosService();

  /// Method that launches the Add Photo screen and awaits the result from Navigator.pop
  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the Add News Screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddPhoto()));

    // after the Add Photo Screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.galleryTitle),
        leading: new Icon(Icons.collections),
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [PopupMenuItem(child: Text(AppString.about)), PopupMenuItem(child: Text(AppString.contact))];
            },
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Photo>>(
          future: photosService.fetchPhotos(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GridView.count(
                childAspectRatio: 1.5,
                crossAxisCount: 2,
                children: List.generate(snapshot.data.length, (index) {
                  return new PhotoCard(snapshot.data[index], photosService);
                }),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner
            return CircularProgressIndicator();
          },
        ),
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
              colors: [Colors.blue[300], Colors.green[300]],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(0.0, 1.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          elevation: 0.0,
          child: new Icon(Icons.add),
          backgroundColor: Colors.red[700],
          onPressed: () {
            _navigateAndDisplaySelection(context);
          },),
    );
  }
}
