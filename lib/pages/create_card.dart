import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../database/model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/audio_source.dart';

class CreateCardScreen extends StatefulWidget {
  const CreateCardScreen({Key? key}) : super(key: key);

  @override
  State<CreateCardScreen> createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends State<CreateCardScreen> {
  final cardBox = Hive.box('cardBox');
  var id = 0;
  var cardName = '';
  var cardText = '';
  var pict = [];
  var rec = [];
  var type = 'noteCard';
  var idList = [];

  var tmpsave = 1; // check card data import
  var tempIndex = -1; //for check playing rec index

  final _picker = ImagePicker();
  final audioRecorder = Record();
  final player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    //RECEIVER from route
    final tempcard = ModalRoute.of(context)?.settings.arguments as DbCard?;
    if ((tempcard != null) && (tmpsave == 1)) {
      id = tempcard.id;
      cardName = tempcard.name;
      cardText = tempcard.text;
      pict = tempcard.pict;
      rec = tempcard.rec;
      type = tempcard.type;
      idList = tempcard.idList;
      tmpsave = 0;
    } else if (tmpsave == 1) {
      //get max ID,then create Card object
      try {
        id = cardBox.keys.last + 1;
      } on StateError {
        id = 0;
      }
      tmpsave == 0;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      //APPBAR, Save button
      appBar: AppBar(
        title: const Text("Card"),
        centerTitle: true,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blueGrey,
              shape: const BeveledRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2))),
              textStyle: const TextStyle(fontSize: 15),
            ),
            onPressed: () {
              // Go to the next page, the pages overlap
              //get max ID in DB,then create Card object
              DbCard card = DbCard(
                  id: id,
                  name: cardName,
                  text: cardText,
                  pict: pict,
                  time: DateTime.now().toString().substring(0, 19),
                  rec: rec,
                  type: type,
                  idList: idList);
              // push Card in DB, then go to Home page
              cardBox.put(id, card.toMap()).then((_) =>
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false));
            },
            child: const Text("Save"),
          )
        ],
      ),

      //BODY
      // 2 Textfields, Records, Images
      body: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          children: [
            //CARD NAME
            TextFormField(
              initialValue: cardName,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(labelText: 'Card Name'),
              onChanged: (val) => cardName = val,
            ),
            //CARD TEXT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: TextFormField(
                initialValue: cardText,
                maxLines: null,
                minLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter text',
                ),
                onChanged: (val) => cardText = val,
              ),
            ),
            //PLAY RECORD
            if (rec.isNotEmpty)
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  child: SizedBox(
                      height: 95,
                      child: ListView.separated(
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 1),
                          itemCount: rec.length,
                          itemBuilder: (context, index) {
                            return playButtons(index, id, rec);
                          }))),
            //LIST WITH PICTURES
            if (pict.isNotEmpty)
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                  child: SizedBox(
                      height: 500,
                      child: ListView.builder(
                        itemCount: pict.length,
                        itemBuilder: (context, index) {
                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // BODY
                                    Text((index + 1).toString()),
                                    IconButton(
                                        icon: const Icon(Icons.share),
                                        onPressed: () async {
                                          final box = this
                                              .context
                                              .findRenderObject() as RenderBox?;
                                          String fileName =
                                              "img_${DateTime.now().millisecondsSinceEpoch}.jpg";
                                          var path = "";
                                          if (!kIsWeb) {
                                            await getTemporaryDirectory()
                                                .then((dir) async {
                                              path = "${dir.path}/$fileName";
                                              File(path).writeAsBytesSync(
                                                  pict[index]);
                                            });
                                          }
                                          XFile xfile = XFile.fromData(
                                              pict[index],
                                              mimeType: 'image/jpeg',
                                              name: fileName,
                                              path: path);
                                          await Share.shareXFiles([xfile],
                                              subject: cardName,
                                              sharePositionOrigin: box!
                                                      .localToGlobal(
                                                          Offset.zero) &
                                                  box.size);
                                        }),
                                    IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          setState(() {
                                            pict.removeAt(index);
                                          });
                                        }),
                                  ],
                                ),
                                Image.memory(
                                  pict[index],
                                  errorBuilder: (BuildContext context,
                                      Object exception,
                                      StackTrace? stackTrace) {
                                    return const Text("");
                                  },
                                ),
                              ]);
                        },
                      )))
          ]),

      // BOTTOM BAR: DELETE, MIC, PICTURE, CAMERA
      bottomNavigationBar: BottomAppBar(
        color: Colors.white38,
        elevation: 10,
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              //DELETE Card
              IconButton(
                padding: const EdgeInsets.fromLTRB(2.0, 2.0, 20.0, 2.0),
                icon: const Icon(Icons.delete),
                iconSize: 40.0,
                onPressed: () {
                  cardBox.delete(id);
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
                },
              ),
              //RECORD sounds
              IconButton(
                padding: const EdgeInsets.fromLTRB(2.0, 2.0, 20.0, 2.0),
                icon: const Icon(Icons.mic),
                onPressed: () async => micDialog(),
                iconSize: 40.0,
              ),
              //ADD Image
              IconButton(
                padding: const EdgeInsets.fromLTRB(2.0, 2.0, 20.0, 2.0),
                icon: const Icon(Icons.image),
                iconSize: 40.0,
                onPressed: () async {
                  XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  image?.readAsBytes().then((value) {
                    setState(() {
                      pict.add(value);
                    });
                  });
                },
              ),
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
                      time: DateTime.now().toString().substring(0, 19),
                      rec: rec,
                      type: type,
                      idList: idList);
                  Navigator.pushNamed(context, '/TakePictureScreen',
                      arguments: tempCard);
                },
              ),
            ]),
      ),
    );
  }

//RECORD DIALOG
  Future micDialog() async {
    // Check and request permission
    if (await audioRecorder.hasPermission()) {
      // Start recording
      await audioRecorder.start();
    }
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
                title: const Text('RECORD BEGIN'),
                content: const Text(''),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      audioRecorder
                          .dispose()
                          .then((value) => Navigator.pop(context));
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      audioRecorder.stop().then((value) {
                        if (kIsWeb) {
                          http.readBytes(Uri.parse(value!)).then((value) {
                            setState(() => rec.add(value));
                            Navigator.pop(context);
                          });
                        } else {
                          File audioFile = File(value!);
                          setState(() => rec.add(audioFile.readAsBytesSync()));
                          Navigator.pop(context);
                        }
                      });
                    },
                    child: const Text('STOP record'),
                  )
                ]));
  }

//RECORDS BUTTONS
  playButtons(index, int id, rec) {
    return Card(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(
          children: [
            const SizedBox(width: 10),
            Text((index + 1).toString()),
            IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
                icon: const Icon(Icons.play_arrow),
                onPressed: () async {
                  if (player.playerState.playing != false ||
                      index != tempIndex ||
                      player.playerState.processingState ==
                          ProcessingState.idle) {
                    tempIndex = index;
                    await player.setAudioSource(MyCustomSource(rec[index]));
                    await player.play();
                  } else {
                    await player.play();
                  }
                }),
            IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                icon: const Icon(Icons.pause),
                onPressed: () async {
                  await player.pause();
                }),
            IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                icon: const Icon(Icons.stop),
                onPressed: () async {
                  await player.stop();
                }),
          ],
        ),
        IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final box = context.findRenderObject() as RenderBox?;
              String fileName =
                  "rec_${DateTime.now().millisecondsSinceEpoch}.m4a";
              var path = "";
              if (!kIsWeb) {
                await getTemporaryDirectory().then((dir) async {
                  path = "${dir.path}/$fileName";
                  File(path).writeAsBytesSync(rec[index]);
                });
              }
              XFile xfile = XFile.fromData(rec[index],
                  mimeType: 'audio/mp4', name: fileName, path: path);
              await Share.shareXFiles([xfile],
                  subject: cardName,
                  sharePositionOrigin:
                      box!.localToGlobal(Offset.zero) & box.size);
            }),
        IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                this.rec.removeAt(index);
              });
            }),
      ]),
    );
  }
}
