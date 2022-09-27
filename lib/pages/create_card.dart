import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../database/model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import  'package:audioplayers/audioplayers.dart';

class CreateCardScreen extends StatefulWidget {
  const CreateCardScreen({Key? key}) : super(key: key);

  @override
  State<CreateCardScreen> createState() => _CreateCardScreenState();
}
class _CreateCardScreenState extends State<CreateCardScreen> {
  final box = Hive.box('cardBox');
  var id = 0;
  var cardName = '';
  var cardText = '';
  var pict = Uint8List(1);
  var rec = Uint8List(1);
  var tmpsave = 1;

  final _picker = ImagePicker();
  final audioRecorder = Record();
  final player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    //RECEIVER from route
    final tempcard = ModalRoute.of(context)?.settings.arguments as DbCard?;
    if ((tempcard != null) && (tmpsave == 1)){
      id =  tempcard.id;
      cardName = tempcard.name;
      cardText = tempcard.text;
      pict = tempcard.pict;
      rec = tempcard.rec;
      tmpsave = 0;
    } else if (tmpsave == 1) {
      //get max ID,then create Card object
      try {
        id = box.keys.last + 1;
      } on StateError{
        id = 0;
      }
      tmpsave == 0;
    }
    if (rec.length > 1) {
      player.setSourceBytes(rec);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      //AppBar, Save button
      appBar: AppBar(
        title: const Text("Card"),
        centerTitle: true,
        actions: [
          TextButton(
            style:  TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blueGrey,
              shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2))),
              textStyle: const TextStyle(fontSize: 15),),
              onPressed: () {
                // Go to the next page, the pages overlap
                //Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                // Navigator.pushNamed(context, '/home'); //Not overlap
                //get max ID in DB,then create Card object
                DbCard card = DbCard(id: id,
                      name: cardName,
                      text: cardText,
                      pict: pict,
                      time: DateTime.now().toString().substring(0,19),
                      rec: rec);
                // push Card in DB, then go to Home page
                box.put(id, card.toMap()).then((_) =>
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false));
                },
              child: const Text("Save"),)
        ],
      ),
      // 2 Textfields, 1 image
      body: Column(
        children: [
        TextFormField(
          initialValue: cardName,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(labelText: 'Card Name'),
          onChanged:  (val) => cardName = val,
        ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextFormField(
              initialValue: cardText,
              maxLines: null,
              minLines: null,
              decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter text',),
              onChanged:(val) => cardText = val,
            ),),
          //PLAY RECORD
          if (rec.length > 1) Card(child: Row(
               children:[
                 IconButton(
                     padding: const EdgeInsets.fromLTRB(8.0,8.0,20.0,8.0),
                     icon: const Icon(Icons.play_arrow),
                     onPressed: () async{
                     await player.resume();
                 }),
                 IconButton(
                     padding: const EdgeInsets.fromLTRB(8.0,8.0,20.0,8.0),
                     icon: const Icon(Icons.pause),
                     onPressed: () async{
                       await player.pause();
                     }),
                 IconButton(
                     padding: const EdgeInsets.fromLTRB(8.0,8.0,20.0,8.0),
                     icon: const Icon(Icons.stop),
                     onPressed: () async{
                       await player.stop();
                     }),
           ]),),
          //SHOW PICTURE
          Expanded(
           child:Image.memory(pict,
                  fit: BoxFit.fitWidth,
                  errorBuilder:  (BuildContext context,
                    Object exception, StackTrace? stackTrace) {
              return const Text("");}, //Error Builder
          ),)
        ]),
      // BOTTOM BAR: DELETE, MIC, PICTURE, CAMERA
      bottomNavigationBar: BottomAppBar(
        color: Colors.white38,
        elevation: 10,
        child: Row (
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //DELETE Card
            IconButton(
              padding: const EdgeInsets.fromLTRB(8.0,8.0,20.0,8.0),
              icon: const Icon(Icons.delete),
              iconSize: 40.0,
              onPressed: () {
                box.delete(id);
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                },),
            //RECORD sounds
            IconButton(
              padding: const EdgeInsets.fromLTRB(8.0,8.0,20.0,8.0),
              icon: const Icon(Icons.mic),
              onPressed: () async => micdialog(),
              iconSize: 40.0,),
            //ADD Image
            IconButton(
              padding: const EdgeInsets.fromLTRB(8.0,8.0,20.0,8.0),
              icon: const Icon(Icons.image),
              iconSize: 40.0,
              onPressed: () async {
                XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                image?.readAsBytes().then((value) {
                  setState(() {pict = value;});
                });
              },),
            //ADD Photo
            IconButton(
              // Go to the next page, the pages overlap
              icon: const Icon(Icons.camera),
              iconSize: 40.0,
              onPressed: () {
                DbCard tempCard = DbCard(
                    id: id,
                    name: cardName,
                    text: cardText,
                    pict: pict,
                    time: DateTime.now().toString().substring(0,19),
                    rec: rec);
                Navigator.pushNamed(context, '/TakePictureScreen',
                arguments: tempCard);
                },
            ),
        ]),
      ),
    );
  }

  Future micdialog () async {
    // Check and request permission
    if (await audioRecorder.hasPermission()) {
    // Start recording
    await audioRecorder.start();
    }
    return showDialog(context: context,
        builder: (BuildContext context) =>
        AlertDialog(
         title: const Text('RECORD BEGIN'),
         content: const Text(''),
         actions: <Widget>[
         TextButton(
           onPressed: () {
               audioRecorder.dispose().then((value) => Navigator.pop(context));
           },
           child: const Text('Cancel'),
    ),
         TextButton(
            onPressed: () {
              audioRecorder.stop().then((value) {
                File audioFile = File(value!);
                setState(() => rec = audioFile.readAsBytesSync());
                Navigator.pop(context);
              });
            },
            child: const Text('STOP record'),
         )
         ]
        )
    );
  }
}

