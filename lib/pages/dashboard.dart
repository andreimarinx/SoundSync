import 'package:animated_loading_border/animated_loading_border.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrcloud/flutter_acrcloud.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/auth.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, required this.title});
  final String title;

  @override
  State<Dashboard> createState() => _Dashboard();
}

class _Dashboard extends State<Dashboard> {
  late AnimationController LoaningController;
  bool trackFound = false;
  ACRCloudResponseMusicItem? music;
  var user = AuthService().user;
  bool _enabled = true;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? apiKey = dotenv.env['ACR_KEY'];
  String host = 'identify-eu-west-1.acrcloud.com';
  String? apiSecret = dotenv.env['API_SECRET'];
  int Hearings = 0, Likes = 0, Searches = 0;
  List<dynamic> savedTracks = [];
  @override
  void initState() {
    super.initState();
    ACRCloud.setUp(ACRCloudConfig(apiKey!, apiSecret!, host));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    // Get reference to Firestore collection
    var collectionRef = firestore.collection('users');
    var doc = await collectionRef.doc(user!.uid).get();
    if (doc.data() == null) {
      print('adding');
      var data = {
        'name': user!.displayName,
        'email': user!.email,
        'saved': {},
        'Hearings': 0,
        'Likes': 0,
        "Searches": 0
      };

      var ref = firestore.collection('users').doc(user!.uid);
      await ref.set(data, SetOptions(merge: true));
    } else {
      print('its here');
      setState(() {
        savedTracks = doc!.data()!['saved'];
        Hearings = doc!.data()!['Hearings'];
        Likes = doc!.data()!['Likes'];
        Searches = doc!.data()!['Searches'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF10102D),
        appBar: AppBar(
          flexibleSpace: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[Color(0xFFB030B0), Color(0xFF602080)]))),
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.white),
          ),
        ),
        drawer: Drawer(
          backgroundColor: Color(0xFF10102D),
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: Container(
            child: Column(
              // Important: Remove any padding from the ListView.

              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.only(top: 80, left: 5, right: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            Color(0xFFB030B0),
                            Color(0xFF602080)
                          ])),
                  child: Center(
                    child: Text(
                      "SOUNDSYNC",
                      style: TextStyle(color: Colors.white, fontSize: 26),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            Color(0xFFB030B0),
                            Color(0xFF602080)
                          ])),
                  margin: EdgeInsets.only(top: 10, left: 5, right: 5),
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 5,
                    top: 30,
                    bottom: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user!.displayName ?? "",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      Text(
                        user!.email ?? "",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                    onTap: () async => {
                          setState(() {
                            trackFound = false;
                          }),
                          Navigator.pop(context)
                        },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(
                          top: 10, left: 5, right: 5, bottom: 50),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                Color(0xFFB030B0),
                                Color(0xFF602080)
                              ])),
                      child: Center(
                        child: Text(
                          "Home",
                          style: TextStyle(color: Colors.white, fontSize: 17),
                        ),
                      ),
                    )),
                Expanded(child: Container()),
                GestureDetector(
                  onTap: () async => {
                    await AuthService().signOut(),
                    if (mounted)
                      {
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil('/', (route) => false)
                      },
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin:
                        EdgeInsets.only(top: 0, left: 5, right: 5, bottom: 50),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              Color(0xFFB030B0),
                              Color(0xFF602080)
                            ])),
                    child: Center(
                      child: Text(
                        "Sign Out",
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // if (music != null) ...[
              //   Text('Track: ${music!.title}\n'),
              //   Text('Album: ${music!.album.name}\n'),
              //   Text('Artist: ${music!.artists.first.name}\n'),
              // ],
              // ElevatedButton(
              //   onPressed: () async => {
              //     if (!await launchUrl(Uri.parse(
              //         'https://play.spotify.com/search/artist:Remi%20track:Sangria')))
              //       {throw Exception('Could not launch url')}
              //   },
              //   child: Text('Search Spotify'),
              // ),

              //top widget
              Visibility(
                  visible: !trackFound,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Start Discovering",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(
                              left: 10, right: 10, top: 10, bottom: 10),
                          margin: EdgeInsets.only(top: 5, bottom: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomLeft,
                                  colors: <Color>[
                                    Color(0xFF202060),
                                    Color(0xFF602080)
                                  ])),
                          height: 115,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: const Color(0xFFB030B0),
                                ),
                                width: 110,
                                height: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Hearings",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      Hearings.toString(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 40),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: const Color(0xFFB030B0),
                                ),
                                width: 110,
                                height: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Likes",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      Likes.toString(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 40),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: const Color(0xFFB030B0),
                                ),
                                width: 110,
                                height: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Searches",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      Searches.toString(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 40),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )),
                      //Listen Button

                      Builder(
                        builder: (context) => GestureDetector(
                            onTap: _enabled
                                ? () async {
                                    setState(() => _enabled = false);
                                    setState(() {
                                      LoaningController.repeat();
                                      Hearings += 1;
                                    });
                                    firestore
                                        .collection('users')
                                        .doc(user!.uid)
                                        .set({'Hearings': Hearings},
                                            SetOptions(merge: true));
                                    final session = ACRCloud.startSession();

                                    // ScaffoldMessenger.of(context)
                                    //     .showSnackBar(SnackBar(
                                    //   backgroundColor: Color(0xFFB030B0),
                                    //   content: StreamBuilder(
                                    //       stream: session.volumeStream,
                                    //       initialData: 0,
                                    //       builder: (_, snapshot) => Row(
                                    //             mainAxisAlignment:
                                    //                 MainAxisAlignment.spaceBetween,
                                    //             children: [
                                    //               Text(
                                    //                 "Listening..  " +
                                    //                     snapshot.data.toString(),
                                    //                 style: TextStyle(
                                    //                     color: Colors.white),
                                    //               ),
                                    //             ],
                                    //           )),
                                    // ));
                                    //onPressed: session.cancel,
                                    final result = await session.result;
                                    if (result == null) {
                                      setState(() {
                                        _enabled = true;
                                      });

                                      LoaningController.reset();
                                      // Cancelled.
                                      return;
                                    } else if (result.metadata == null) {
                                      setState(() {
                                        _enabled = true;
                                      });
                                      LoaningController.reset();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        backgroundColor: Color(0xFFB030B0),
                                        content: Text('No result.'),
                                      ));
                                      return;
                                    }
                                    print('found');
                                    setState(() {
                                      LoaningController.reset();
                                      _enabled = true;
                                      trackFound = true;
                                      music = result.metadata!.music.first;
                                    });
                                  }
                                : null,
                            child: AnimatedLoadingBorder(
                              cornerRadius: 5,
                              isTrailingTransparent: true,
                              borderWidth: 5,
                              duration: const Duration(seconds: 2),
                              borderColor: Colors.white,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: const Color(0xFF602080),
                                ),
                                height: 222,
                                child: Center(
                                    child: Image.asset(
                                  './lib/assets/icon.png',
                                  height: 60,
                                )),
                              ),
                              controller: (animationController) {
                                LoaningController = animationController;
                                LoaningController.reset();
                              },
                            )),
                      ),
                    ],
                  )),

              //track found
              if (music != null) ...[
                Visibility(
                    visible: trackFound,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Success!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.only(
                                left: 20, right: 20, top: 10, bottom: 10),
                            margin: EdgeInsets.only(top: 5, bottom: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomLeft,
                                    colors: <Color>[
                                      Color(0xFF202060),
                                      Color(0xFF602080)
                                    ])),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Name',
                                      style: TextStyle(
                                          color: Color(0xFFD1D1D1),
                                          fontSize: 15),
                                    ),
                                    Text(
                                      music!.title,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "Album",
                                      style: TextStyle(
                                          color: Color(0xFFD1D1D1),
                                          fontSize: 15),
                                    ),
                                    Text(
                                      music!.album.name,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Artist',
                                      style: TextStyle(
                                          color: Color(0xFFD1D1D1),
                                          fontSize: 15),
                                    ),
                                    Text(
                                      music!.artists.first.name,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                savedTracks.contains(music!.title.toString() +
                                        "^" +
                                        music!.album.name.toString() +
                                        "^" +
                                        music!.artists.first.name.toString())
                                    ? GestureDetector(
                                        onTap: () async => {
                                          setState(() {
                                            savedTracks.remove(music!.title
                                                    .toString() +
                                                "^" +
                                                music!.album.name.toString() +
                                                "^" +
                                                music!.artists.first.name
                                                    .toString());
                                            Likes -= 1;
                                          }),
                                          firestore
                                              .collection('users')
                                              .doc(user!.uid)
                                              .set({
                                            'saved': savedTracks,
                                            'Likes': Likes
                                          }, SetOptions(merge: true))
                                        },
                                        child: Image.asset(
                                          './lib/assets/like_heart.png',
                                          height: 24,
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () => {
                                          setState(() {
                                            savedTracks.insert(
                                                0,
                                                music!.title.toString() +
                                                    "^" +
                                                    music!.album.name
                                                        .toString() +
                                                    "^" +
                                                    music!.artists.first.name
                                                        .toString());
                                            Likes += 1;
                                          }),
                                          firestore
                                              .collection('users')
                                              .doc(user!.uid)
                                              .set({
                                            'saved': savedTracks,
                                            "Likes": Likes
                                          }, SetOptions(merge: true))
                                        },
                                        child: Image.asset(
                                          './lib/assets/heart.png',
                                          height: 24,
                                        ),
                                      ),
                              ],
                            )),
                        Text(
                          "Search on...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          Searches += 1;
                                        });
                                        firestore
                                            .collection('users')
                                            .doc(user!.uid)
                                            .set({'Searches': Searches},
                                                SetOptions(merge: true));
                                        dynamic url =
                                            "https://open.spotify.com/search/${music!.artists.first.name.replaceAll(' ', '%20')}%20${music!.title.replaceAll(' ', '%20')}";
                                        if (await canLaunch(url)) {
                                          await launch(url);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      child: Container(
                                        height: 40,
                                        margin: EdgeInsets.only(bottom: 5),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        padding: EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 5,
                                            bottom: 5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: const Color(0xFF202060),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              './lib/assets/spotify.png',
                                              width: 25,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              'Spotify',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                      )),
                                  GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          Searches += 1;
                                        });
                                        firestore
                                            .collection('users')
                                            .doc(user!.uid)
                                            .set({'Searches': Searches},
                                                SetOptions(merge: true));
                                        dynamic url =
                                            "https://soundcloud.com/search?q=${music!.artists.first.name.replaceAll(' ', '%20')}%20${music!.title.replaceAll(' ', '%20')}";

                                        if (await canLaunch(url)) {
                                          await launch(url);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      child: Container(
                                        height: 40,
                                        margin: EdgeInsets.only(bottom: 5),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        padding: EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 5,
                                            bottom: 5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: const Color(0xFF202060),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              './lib/assets/soundcloud2.png',
                                              width: 25,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              'Soundcloud',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          Searches += 1;
                                        });
                                        firestore
                                            .collection('users')
                                            .doc(user!.uid)
                                            .set({'Searches': Searches},
                                                SetOptions(merge: true));
                                        dynamic url =
                                            "https://www.youtube.com/results?search_query=${music!.artists.first.name.replaceAll(' ', '+')}+${music!.title.replaceAll(' ', '+')}";

                                        if (await canLaunch(url)) {
                                          await launch(url);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      child: Container(
                                        height: 40,
                                        margin: EdgeInsets.only(bottom: 5),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        padding: EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 5,
                                            bottom: 5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: const Color(0xFF202060),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              './lib/assets/youtube.png',
                                              width: 30,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              'Youtube',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                      )),
                                  GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          Searches += 1;
                                        });
                                        firestore
                                            .collection('users')
                                            .doc(user!.uid)
                                            .set({'Searches': Searches},
                                                SetOptions(merge: true));
                                        dynamic url =
                                            "https://music.apple.com/us/search?term=${music!.artists.first.name.replaceAll(' ', '%20')}%20${music!.title.replaceAll(' ', '%20')}";

                                        if (await canLaunch(url)) {
                                          await launch(url);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      child: Container(
                                        height: 40,
                                        margin: EdgeInsets.only(bottom: 5),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        padding: EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 5,
                                            bottom: 5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: const Color(0xFF202060),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              './lib/assets/apple.png',
                                              width: 20,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              'Apple',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                      )),
                                ],
                              )
                            ],
                          ),
                        ),
                        //small button
                        Builder(
                          builder: (context) => GestureDetector(
                              onTap: _enabled
                                  ? () async {
                                      setState(() => _enabled = false);
                                      setState(() {
                                        LoaningController.repeat();
                                        Hearings += 1;
                                      });
                                      firestore
                                          .collection('users')
                                          .doc(user!.uid)
                                          .set({'Hearings': Hearings},
                                              SetOptions(merge: true));
                                      final session = ACRCloud.startSession();

                                      // ScaffoldMessenger.of(context)
                                      //     .showSnackBar(SnackBar(
                                      //   backgroundColor: Color(0xFFB030B0),
                                      //   content: StreamBuilder(
                                      //     stream: session.volumeStream,
                                      //     initialData: 0,
                                      //     builder: (_, snapshot) => Text(
                                      //       "Listening..  " +
                                      //           snapshot.data.toString(),
                                      //       style: TextStyle(color: Colors.white),
                                      //     ),
                                      //   ),
                                      // ));
                                      //onPressed: session.cancel,
                                      final result = await session.result;

                                      if (result == null) {
                                        // Cancelled.
                                        setState(() {
                                          _enabled = true;
                                        });
                                        LoaningController.reset();
                                        return;
                                      } else if (result.metadata == null) {
                                        setState(() {
                                          _enabled = true;
                                        });
                                        LoaningController.reset();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          backgroundColor: Color(0xFFB030B0),
                                          content: Text('No result.'),
                                        ));
                                        return;
                                      }

                                      setState(() {
                                        _enabled = true;
                                        trackFound = true;
                                        LoaningController.reset();
                                        music = result.metadata!.music.first;
                                      });
                                    }
                                  : null,
                              child: AnimatedLoadingBorder(
                                cornerRadius: 5,
                                isTrailingTransparent: true,
                                borderWidth: 3,
                                duration: const Duration(seconds: 2),
                                borderColor: Colors.white,
                                child: Container(
                                  margin: EdgeInsets.only(top: 0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: const Color(0xFF602080),
                                  ),
                                  height: 40,
                                  child: Center(
                                      child: Image.asset(
                                    './lib/assets/icon.png',
                                    height: 60,
                                  )),
                                ),
                                controller: (animationController) {
                                  LoaningController = animationController;
                                  LoaningController.stop();
                                },
                              )),
                        ),
                      ],
                    )),
              ],

              //saved tracks
              Container(
                  padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                  margin: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Color(0xFFB030B0),
                            Color(0xFF602080)
                          ])),
                  height: 290,
                  child: ListView(
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(bottom: 10),
                          width: double.infinity,
                          child: Text(
                            'Saved Tracks',
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          )),

                      //card

                      Container(
                          width: double.infinity,
                          child: Column(
                              children: savedTracks.map((trackInfo) {
                            print(trackInfo);
                            dynamic splitted = trackInfo.split('^');

                            return Container(
                                margin: EdgeInsets.only(bottom: 5),
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, top: 5, bottom: 5),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: const Color(0xFF602080),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () => showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          backgroundColor: Color(0xFF602080),
                                          content: Container(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Text(
                                                        splitted[0],
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        splitted[2],
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    ]),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: 5, top: 10),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: <Widget>[
                                                      Column(
                                                        children: <Widget>[
                                                          GestureDetector(
                                                            onTap: () async {
                                                              setState(() {
                                                                Searches += 1;
                                                              });
                                                              firestore
                                                                  .collection(
                                                                      'users')
                                                                  .doc(
                                                                      user!.uid)
                                                                  .set(
                                                                      {
                                                                    'Searches':
                                                                        Searches
                                                                  },
                                                                      SetOptions(
                                                                          merge:
                                                                              true));
                                                              dynamic url =
                                                                  "https://open.spotify.com/search/${splitted[2].replaceAll(' ', '%20')}%20${splitted[0].replaceAll(' ', '%20')}";
                                                              if (await canLaunch(
                                                                  url)) {
                                                                await launch(
                                                                    url);
                                                              } else {
                                                                throw 'Could not launch $url';
                                                              }
                                                            },
                                                            child: Container(
                                                              height: 40,
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      bottom:
                                                                          5),
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.45,
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 10,
                                                                      right: 10,
                                                                      top: 5,
                                                                      bottom:
                                                                          5),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                color: const Color(
                                                                    0xFF202060),
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Image.asset(
                                                                    './lib/assets/spotify.png',
                                                                    width: 25,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Text(
                                                                    'Spotify',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                              onTap: () async {
                                                                setState(() {
                                                                  Searches += 1;
                                                                });
                                                                firestore
                                                                    .collection(
                                                                        'users')
                                                                    .doc(user!
                                                                        .uid)
                                                                    .set({
                                                                  'Searches':
                                                                      Searches
                                                                }, SetOptions(merge: true));
                                                                dynamic url =
                                                                    "https://www.youtube.com/results?search_query=${splitted[2].replaceAll(' ', '+')}+${splitted[0].replaceAll(' ', '+')}";

                                                                if (await canLaunch(
                                                                    url)) {
                                                                  await launch(
                                                                      url);
                                                                } else {
                                                                  throw 'Could not launch $url';
                                                                }
                                                              },
                                                              child: Container(
                                                                height: 40,
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        bottom:
                                                                            5),
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.45,
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            10,
                                                                        top: 5,
                                                                        bottom:
                                                                            5),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  color: const Color(
                                                                      0xFF202060),
                                                                ),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Image.asset(
                                                                      './lib/assets/youtube.png',
                                                                      width: 30,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text(
                                                                      'Youtube',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    )
                                                                  ],
                                                                ),
                                                              )),
                                                          GestureDetector(
                                                              onTap: () async {
                                                                setState(() {
                                                                  Searches += 1;
                                                                });
                                                                firestore
                                                                    .collection(
                                                                        'users')
                                                                    .doc(user!
                                                                        .uid)
                                                                    .set({
                                                                  'Searches':
                                                                      Searches
                                                                }, SetOptions(merge: true));
                                                                dynamic url =
                                                                    "https://soundcloud.com/search?q=${splitted[2].replaceAll(' ', '%20')}%20${splitted[0].replaceAll(' ', '%20')}";

                                                                if (await canLaunch(
                                                                    url)) {
                                                                  await launch(
                                                                      url);
                                                                } else {
                                                                  throw 'Could not launch $url';
                                                                }
                                                              },
                                                              child: Container(
                                                                height: 40,
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        bottom:
                                                                            5),
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.45,
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            10,
                                                                        top: 5,
                                                                        bottom:
                                                                            5),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  color: const Color(
                                                                      0xFF202060),
                                                                ),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Image.asset(
                                                                      './lib/assets/soundcloud2.png',
                                                                      width: 25,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text(
                                                                      'Soundcloud',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    )
                                                                  ],
                                                                ),
                                                              )),
                                                          GestureDetector(
                                                              onTap: () async {
                                                                setState(() {
                                                                  Searches += 1;
                                                                });
                                                                firestore
                                                                    .collection(
                                                                        'users')
                                                                    .doc(user!
                                                                        .uid)
                                                                    .set({
                                                                  'Searches':
                                                                      Searches
                                                                }, SetOptions(merge: true));
                                                                dynamic url =
                                                                    "https://music.apple.com/us/search?term=${splitted[2].replaceAll(' ', '%20')}%20${splitted[0].replaceAll(' ', '%20')}";

                                                                if (await canLaunch(
                                                                    url)) {
                                                                  await launch(
                                                                      url);
                                                                } else {
                                                                  throw 'Could not launch $url';
                                                                }
                                                              },
                                                              child: Container(
                                                                height: 40,
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        bottom:
                                                                            5),
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.45,
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            10,
                                                                        top: 5,
                                                                        bottom:
                                                                            5),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  color: const Color(
                                                                      0xFF202060),
                                                                ),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Image.asset(
                                                                      './lib/assets/apple.png',
                                                                      width: 20,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text(
                                                                      'Apple',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    )
                                                                  ],
                                                                ),
                                                              )),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              splitted[0],
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              splitted[2],
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white,
                                              ),
                                            )
                                          ]),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () async => {
                                            setState(() {
                                              savedTracks.remove(splitted[0] +
                                                  "^" +
                                                  splitted[1] +
                                                  "^" +
                                                  splitted[2]);
                                              Likes -= 1;
                                            }),
                                            firestore
                                                .collection('users')
                                                .doc(user!.uid)
                                                .set({
                                              'saved': savedTracks,
                                              'Likes': Likes
                                            }, SetOptions(merge: true))
                                          },
                                          child: Image.asset(
                                            './lib/assets/like_heart.png',
                                            height: 24,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ));
                          }).toList())),
                      savedTracks.length < 4 ? emptyCard() : SizedBox(),
                      savedTracks.length < 3 ? emptyCard() : SizedBox(),
                      savedTracks.length < 2 ? emptyCard() : SizedBox(),
                      savedTracks.length < 1 ? emptyCard() : SizedBox(),
                    ],
                  ))
            ],
          ),
        ),
      );
    } else {
      return SizedBox();
    }
  }
}

Widget emptyCard() {
  return Container(
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: const Color(0xFF602080),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 5),
                  height: 12,
                  width: 120,
                  color: Colors.white.withOpacity(.4),
                ),
                Container(
                  height: 12,
                  width: 200,
                  color: Colors.white.withOpacity(.4),
                ),
              ]),
          Row(
            children: <Widget>[
              Image.asset(
                './lib/assets/heart.png',
                opacity: const AlwaysStoppedAnimation(.4),
                height: 24,
              )
            ],
          )
        ],
      ));
  ;
}
