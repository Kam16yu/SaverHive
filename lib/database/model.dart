class DbCard {
  int id = 1;
  String name = "null name";
  String text = "null text";
  List pict = [];
  String time = "null time";
  List rec = [];
  String type = 'noteCard';
  List idList = [];

  //Constructor
  DbCard(
      {required this.id,
      required this.name,
      required this.text,
      required this.pict,
      required this.time,
      required this.rec,
      required this.type,
      required this.idList});

  //Create Card from map
  static DbCard cardFromMap(mapObject) {
    return DbCard(
        id: mapObject['id'],
        name: mapObject['name'],
        text: mapObject['text'],
        pict: mapObject['pict'],
        time: mapObject['time'],
        rec: mapObject['rec'],
        type: mapObject['type'],
        idList: mapObject['idList']);
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
      'rec': rec,
      'type': type,
      'idList': idList
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Card{id: $id, name: $name, text: $text, time: $time}';
  }
}
