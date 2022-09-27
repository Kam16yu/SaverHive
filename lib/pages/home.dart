import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import '../database/model.dart';


class Home extends StatefulWidget{
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final player = AudioPlayer();
  final cardBox = Hive.box("cardBox");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //Appbar, Setting Menu Button
      appBar: AppBar(
        title: const Text("Cards"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: _menuOpen, icon: const Icon(Icons.menu_outlined))
        ],
      ),

      //Body
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child:  ListView.builder(
          itemCount: cardBox.length,
          itemBuilder: (context, index) {
            DbCard card = DbCard.cardFromMap(cardBox.getAt(index));
            return Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
              side: BorderSide(
              color: Theme.of(context).colorScheme.outline,),
              borderRadius: const BorderRadius.all(Radius.circular(12)),),
              //PRESS SPLASH
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                Navigator.pushNamed(context, '/CreateCardScreen',
                  arguments: card);},
                  //CARD BODY
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                      leading: Image.memory(card.pict,
                        errorBuilder: (BuildContext context,Object exception,
                        StackTrace? stackTrace) {return const Text("");},
                      ),
                      title: Text(card.name),
                      subtitle: Text(card.text),
                      ),
                      if (card.rec.length >1)
                      Card(child: Row(
                        children: [
                          IconButton(
                          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 20.0, 8.0),
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () async {
                            await player.setSourceBytes(card.rec);
                            await player.resume();
                            }),
                          IconButton(
                            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 20.0, 8.0),
                            icon: const Icon(Icons.pause),
                            onPressed: () async {await player.pause();}),
                          IconButton(
                            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 20.0, 8.0),
                            icon: const Icon(Icons.stop),
                            onPressed: () async {await player.stop();}
                          ),
                        ]
                      ),),
                      //CARD BUTTONS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(card.time,
                            style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0)
                            ),
                          IconButton(
                            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 20.0, 8.0),
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                            Navigator.pushNamed(
                            context, '/CreateCardScreen',
                            arguments: card);},
                            ),
                          IconButton(
                            padding: const EdgeInsets.fromLTRB(
                            8.0, 8.0, 20.0, 8.0),
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                                cardBox.delete(card.id);
                                setState(() {});},
                            ),
                      ],),
                    ]
                ),
              )
            );
          }
        ),
      ),
      // Add element Button

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        onPressed: () {
          Navigator.pushNamed(context, '/CreateCardScreen');
        }, // onPressed
        child: const Icon(
          Icons.add,
          color: Colors.green,),
      ),
    );
  }

  //Setting menu
  void _menuOpen() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(title: const Text("Menu"),),
            body: Row(
              children: [
                TextButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black26)),
                    onPressed: () {
                      cardBox.clear().then((value){
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/', (route) => false);});
                    },
                    child: const Text("Clear ALL")
                ),
              ],
            ),
          );
        })
    );
  }

}

