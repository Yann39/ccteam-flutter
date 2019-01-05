import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';

class Team extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TeamState();
  }
}

class _TeamState extends State<Team> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.teamTitle),
        backgroundColor: Colors.blue[300],
        leading: new Icon(Icons.group),
      ),
      body: new ContactList(kContacts),
    );
  }
}

const kContacts = const <Contact>[
  const Contact(fullName: 'Lisa Bautista', email: 'Lisa.Bautista@example.com'),
  const Contact(fullName: 'Emerson Bartlett', email: 'Emerson.Bartlett@example.com'),
  const Contact(fullName: 'Jewel Spence', email: 'Jewel.Spence@example.com'),
  const Contact(fullName: 'Marlie Russo', email: 'Marlie.Russo@example.com'),
  const Contact(fullName: 'Maryjane Salas', email: 'Maryjane.Salas@example.com'),
  const Contact(fullName: 'Briley Dickerson', email: 'Briley.Dickerson@example.com'),
  const Contact(fullName: 'Lukas Garrett', email: 'Lukas.Garrett@example.com'),
  const Contact(fullName: 'Karter Chandler', email: 'Karter.Karter@example.com'),
  const Contact(fullName: 'Jada Potter', email: 'Jada.Potter@example.com'),
  const Contact(fullName: 'Owen Fischer', email: 'Owen.Fischer@example.com'),
  const Contact(fullName: 'Brody Ho', email: 'Brody.Ho@example.com'),
  const Contact(fullName: 'Amya Gentry', email: 'Amya.Gentry@example.com'),
];

class ContactList extends StatelessWidget {
  final List<Contact> _contacts;

  ContactList(this._contacts);

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new ListView.builder(
        padding: new EdgeInsets.symmetric(vertical: 8.0),
        itemBuilder: (context, index) {
          return new _ContactListItem(_contacts[index]);
        },
        itemCount: _contacts.length,
      ),
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
            colors: [Colors.blue[300], Colors.green[300]],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
    );
  }
}

class _ContactListItem extends ListTile {
  _ContactListItem(Contact contact) : super(title: new Text(contact.fullName), subtitle: new Text(contact.email), leading: new CircleAvatar(child: new Text(contact.fullName[0])));
}

class Contact {
  final String fullName;
  final String email;

  const Contact({this.fullName, this.email});
}
