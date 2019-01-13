/// class representing a track event
class Event {
  int id;
  String title;
  String description;
  DateTime eventDate;
  int trackId;
  String organizer;
  double price;

  Event({this.id, this.title, this.description, this.eventDate, this.trackId, this.organizer, this.price});
}
