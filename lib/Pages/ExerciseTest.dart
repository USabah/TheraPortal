import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:theraportal/Utilities/GoogleDriveRouter.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      largeScreen: LargeScreen(),
    );
  }
}

class LargeScreen extends StatefulWidget {
  @override
  State<LargeScreen> createState() => _LargeScreenState();
}

class _LargeScreenState extends State<LargeScreen> {
  Uint8List? exerciseMedia; // Set an initial value
  GoogleDriveRouter router = GoogleDriveRouter();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(),
        (exerciseMedia == null)
            ? const Text("Data not had")
            : Image.memory(
                exerciseMedia!,
                // Make sure to specify the width and height of the image
                width: 200, // Adjust this according to your preference
                height: 200, // Adjust this according to your preference
                fit: BoxFit.contain, // Adjust the fit as needed
              ),
        Container(
          width: width * 0.3,
          child: FloatingActionButton(
            child: Text("TEST BUTTON"),
            onPressed: () async {
              // await router.listFiles();
              Uint8List? res = await router.getGifContent("test_gif.gif");
              if (res != null) {
                exerciseMedia = res;
                print(exerciseMedia);
                setState(() {});
              }
            },
          ),
        ),
      ],
    );
    // return FutureBuilder<List<String>>(
    //   future: APIRouter().fetchSongs(),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return Center(
    //         child: CircularProgressIndicator(),
    //       );
    //     }
    //     if (snapshot.hasError) {
    //       return Center(
    //         child: Text("error fetching songs"),
    //       );
    //     }
    //     List<String> songs = snapshot.data!;
    //     return SafeArea(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Container(
    //             height: 200,
    //             child: Text(
    //               'test page',
    //               style: TextStyle(
    //                 fontSize: 80,
    //               ),
    //             ),
    //           ),
    //           Expanded(
    //             child: ListView.builder(
    //               itemCount: songs.length,
    //               itemBuilder: (context, index) {
    //                 return FutureBuilder<Song>(
    //                   future: SpotifyRouter().getSong(songs[index]),
    //                   builder: (context, snapshot) {
    //                     if (snapshot.connectionState ==
    //                         ConnectionState.waiting) {
    //                       return ListTile(
    //                         title: Text('Loading... '),
    //                       );
    //                     }
    //                     if (snapshot.hasError) {
    //                       return ListTile(
    //                         title: Text('Error fetching song'),
    //                       );
    //                     }
    //                     Song song = snapshot.data!;
    //                     String formattedSong =
    //                         '${song.name} by ${song.artists.join(", ")}';
    //                     return ListTile(
    //                       title: Text(formattedSong),
    //                     );
    //                   },
    //                 );
    //               },
    //             ),
    //           ),
    //         ],
    //       ),
    //     );
    //   },
    // );

    // return SafeArea(
    //   child: Row(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: [
    //       Container(
    //         child: Text(
    //           'TEST PAGE',
    //           style: TextStyle(
    //             fontSize: 80,
    //             color: Colors.purple,
    //           ),
    //         ),
    //       ),
    //       Column(children: [])
    //     ],
    //   ),
    // );
  }
}

class ExerciseTest extends StatelessWidget {
  static const Key pageKey = Key("Exercise Test");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(),
    );
  }
}
