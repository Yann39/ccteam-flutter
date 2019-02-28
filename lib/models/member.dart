/// class representing a team member
class Member {
  int id;
  String firstName;
  String lastName;
  String email;
  String password;
  bool active;
  String phone;
  String bike;
  DateTime registrationDate;

  Member({this.id, this.firstName, this.lastName, this.email, this.password, this.active, this.phone, this.bike, this.registrationDate});
}
