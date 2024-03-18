import 'package:ccteam/utils/enums.dart';
import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({Key key, this.text, this.type}) : super(key: key);

  final String text;
  final DialogType type;

  @override
  Widget build(BuildContext context) {
    MaterialColor color;
    Icon icon;
    if (type == DialogType.info) {
      color = Colors.blue;
      icon = Icon(Icons.info, color: Colors.white, size: 44);
    } else if (type == DialogType.success) {
      color = Colors.green;
      icon = Icon(Icons.check_circle, color: Colors.white, size: 44);
    } else if (type == DialogType.warning) {
      color = Colors.yellow;
      icon = Icon(Icons.warning_rounded, color: Colors.white, size: 44);
    } else if (type == DialogType.error) {
      color = Colors.red;
      icon = Icon(Icons.error, color: Colors.white, size: 44);
    } else {
      color = Colors.blue;
      icon = Icon(Icons.info, color: Colors.white, size: 44);
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[50], Colors.deepPurple[200]],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(0.0, 1.0),
                  tileMode: TileMode.clamp,
                ),
                borderRadius: BorderRadius.circular(4.0),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black45,
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(2, 3))
                ]),
            padding: EdgeInsets.fromLTRB(10, 40, 10, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Erreur",
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  textScaleFactor: 2,
                ),
                Divider(
                  color: color,
                  thickness: 2,
                  indent: 100,
                  endIndent: 100,
                  height: 30,
                ),
                Text("$text", textAlign: TextAlign.center),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(primary: color),
                  child: Text('OK', style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
          Positioned(
            top: -30,
            child:
                CircleAvatar(backgroundColor: color, radius: 30, child: icon),
          ),
        ],
      ),
    );
  }
}
