import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import '../database/model.dart';
import '../utils/audio_source.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final player = AudioPlayer();
  final cardBox = Hive.box("cardBox");
  var tempIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          snap: false,
          floating: true,
          expandedHeight: 160.0,
          actions: [
            IconButton(
                onPressed: _menuOpen, icon: const Icon(Icons.menu_outlined))
          ],
          flexibleSpace: const FlexibleSpaceBar(
            title: Text('CARDS'),
            background: FlutterLogo(),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(childCount: cardBox.length,
            (BuildContext context, int index) {
          DbCard card = DbCard.cardFromMap(cardBox.getAt(index));
          return Container(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  //PRESS SPLASH
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {
                      Navigator.pushNamed(context, '/CreateCardScreen',
                          arguments: card);
                    },
                    //CARD BODY
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ListTile(
                            leading: pictureShow(card),
                            title: Text(card.name),
                            subtitle: Text(card.text),
                          ),
                          if (card.rec.isNotEmpty) playButtons (card),
                          //CARD BUTTONS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Text(card.time,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0)),
                              IconButton(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 8.0, 20.0, 8.0),
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  Navigator.pushNamed(
                                      context, '/CreateCardScreen',
                                      arguments: card);
                                },
                              ),
                              IconButton(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 8.0, 20.0, 8.0),
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  cardBox.delete(card.id);
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ]),
                  )));
        })),
        // Add element Button
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        onPressed: () {
          Navigator.pushNamed(context, '/CreateCardScreen');
        }, // onPressed
        child: const Icon(
          Icons.add,
          color: Colors.green,
        ),
      ),
    );
  }

  //Setting menu
  void _menuOpen() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Menu"),
        ),
        body: Row(
          children: [
            TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black26)),
                onPressed: () {
                  cardBox.clear().then((value) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  });
                },
                child: const Text("Clear ALL")),
          ],
        ),
      );
    }));
  }

  pictureShow(card) {
    if (card.pict.isNotEmpty) {
      return Image.memory(card.pict[0], errorBuilder:
          (BuildContext context, Object exception, StackTrace? stackTrace) {
        return const Text("");
      });
    } else {
      return const Text("");
    }
  }

  playButtons(DbCard card) {
    return Card(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Row(children: [
            const SizedBox(width: 10),
            IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
                icon: const Icon(Icons.play_arrow),
                onPressed: () async {
                  if (player.playerState.playing != false || card.id != tempIndex
                      || player.playerState.processingState == ProcessingState.idle ) {
                    tempIndex = card.id;
                    await player.setAudioSource(MyCustomSource(card.rec[0]));
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
          ],),]),
    );
  }
}
