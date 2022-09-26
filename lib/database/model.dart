import 'dart:typed_data';

class DbCard {
  var id = 1;
  var name = "null name";
  var text = "null text";
  var pict = Uint8List(1);
  var time = "null time";
  var rec = Uint8List(1);

  //Constructors
  DbCard({required this.id, required this.name, required this.text,
    required this.pict, required this.time, required this.rec});
  //Create Card from map
  static DbCard cardFromMap(map) {
    return DbCard(
      id: map['id'],
      name: map['name'],
      text: map['text'],
      pict: map['pict'],
      time: map['time'],
      rec: map['rec'],);
  }

  // Convert a Card into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'text': text,
      'pict': pict,
      'time': time,
      'rec' : rec
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Card{id: $id, name: $name, text: $text, time: $time}';
  }
}

