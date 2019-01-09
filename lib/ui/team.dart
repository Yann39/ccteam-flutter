import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/services/members_service.dart';
import 'package:chachatte_team/ui/add_member.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';

class Team extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TeamState();
  }
}

/// class representing the floating action button to add a member
/// await the result from the "Add Member" screen to display a message
class _AddMemberButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        elevation: 0.0,
        child: new Icon(Icons.add),
        backgroundColor: Colors.red[700],
        onPressed: () {
          _navigateAndDisplaySelection(context);
        });
  }

  /// Method that launches the Add Member screen and awaits the result from Navigator.pop
  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the Add News Screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddMember()));

    // after the Add News Screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }
}

class _TeamState extends State<Team> {
  static final MembersService membersService = new MembersService();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.teamTitle),
        backgroundColor: Colors.blue[300],
        leading: new Icon(Icons.group),
      ),
      body: /*new ContactList(kContacts),*/
          FutureBuilder<List<Member>>(
        future: membersService.fetchMembers(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new Column(
              children: <Widget>[
                new Expanded(
                    child: new Container(
                        child: new ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              /*return new NewsCard(snapshot.data[index], new AssetImage(helmets[0]), Colors.purple[600], Colors.purple[200]);*/
                              return new _ContactListItem(snapshot.data[index]);
                            }),
                        decoration: new BoxDecoration(
                          gradient: new LinearGradient(
                              colors: [Colors.blue[300], Colors.green[300]],
                              begin: const FractionalOffset(0.0, 0.0),
                              end: const FractionalOffset(0.0, 1.0),
                              stops: [0.0, 1.0],
                              tileMode: TileMode.clamp),
                        )))
              ],
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner
          return CircularProgressIndicator();
        },
      ),
      floatingActionButton: _AddMemberButton(),
    );
  }
}

class _ContactListItem extends ListTile {
  _ContactListItem(Member member)
      : super(title: new Text(member.firstName + " " + member.lastName), subtitle: new Text(member.bike), leading: new CircleAvatar(child: new Text(member.firstName[0])));
}

class Contact {
  final String fullName;
  final String email;

  const Contact({this.fullName, this.email});
}
