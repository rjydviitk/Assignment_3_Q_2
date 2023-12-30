import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Album>> fetchAlbum() async {
  final response =
      await http.get(Uri.parse('https://jsonplaceholder.typicode.com/albums'));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    List<Album> albums = data.map((json) => Album.fromJson(json)).toList();
    return albums;
  } else {
    throw Exception('Failed to load album');
  }
}

Future<Album> createAlbum(String title) async {
  final response = await http.post(
    Uri.parse('https://jsonplaceholder.typicode.com/albums'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'title': title,
      'id': 10299999999999,
      'userId': 1,
    }),
  );

  if (response.statusCode == 201) {
    // Check if the decoded JSON is not null before casting
    final dynamic decodedJson = jsonDecode(response.body);
    if (decodedJson != null && decodedJson is Map<String, dynamic>) {
      return Album.fromJson(decodedJson);
    } else {
      throw Exception('Failed to create album. Decoded JSON is not valid.');
    }
  } else {
    throw Exception('Failed to create album.');
  }
}

// ... (Previous code remains unchanged)

// ... (Remaining code remains unchanged)

// Future<Album> deleteAlbum(String id) async {
//   final http.Response response = await http.delete(
//     Uri.parse('https://jsonplaceholder.typicode.com/albums/$id'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//     },
//   );

//   if (response.statusCode == 200) {
//     return Album.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
//   } else {
//     throw Exception('Failed to delete album.');
//   }
// }

class Album {
  final int userId;
  final int id;
  final String title;

  const Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  const MyApp({Key? key}) : super(key: key);

  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Album>> futureAlbum;
  final TextEditingController title = TextEditingController();

  // @override
  // void initState() {
  //   super.initState();
  //   futureAlbum = fetchAlbum();
  // }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Album>> futureAlbum;
  final TextEditingController title = TextEditingController();
  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> deleteAlbum(
      int albumId,
    ) async {
      // Check if the album with the specified ID exists in the futureAlbum list
      if (futureAlbum != null) {
        setState(() {
          // Remove the album with the specified ID from the list
          futureAlbum = futureAlbum.then((albums) {
            albums.removeWhere((album) => album.id == albumId);
            return albums;
          });
        });
        print("Deleted the ID numbered $albumId");
      } else {
        throw Exception('Failed to delete album.');
      }
    }

    _uploadDialog() async {
      print('hello');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Post Your Quote',
              style: TextStyle(fontSize: 19),
            ),
            content: TextField(
              controller: title,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  createAlbum(title.text.toString());
                  Navigator.of(context).pop();
                  print("Posted");
                },
                child: Text('Upload'),
              ),
            ],
          );
        },
      );
    }

    void handleDeleteAction(int albumId) async {
      try {
        await deleteAlbum(albumId.toString());
        setState(() {
          // Remove the deleted album from the list
          futureAlbum = fetchAlbum();
        });
        print("Deleted the ID numbered $albumId");
      } catch (e) {
        print("Failed to delete the album with ID $albumId: $e");
      }
    }

    _deleteDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Enter ID to Delete',
              style: TextStyle(fontSize: 15),
            ),
            content: TextField(
              controller: title,
              keyboardType: TextInputType.number,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  deleteAlbum(title.text.toString());
                  Navigator.of(context).pop();
                  print("Deleted");
                },
                child: Text('Delete'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 48, 26, 87),
        onPressed: () {
          // createAlbum(title.text.toString());
        },
        child: const Icon(
          Icons.add,
        ),
      ),
      appBar: AppBar(
        title: const Text('Quotes'),
        backgroundColor: Color.fromARGB(255, 37, 7, 74),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Quotes of the day',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FutureBuilder<List<Album>>(
              future: futureAlbum,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    height: 250.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Album album = snapshot.data![index];
                        return Container(
                          width: 200.0,
                          margin: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 76, 75, 77),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      'ID: ${album.id}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                    SizedBox(height: 10.0),
                                    Text(
                                      album.title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 8.0,
                                right: 8.0,
                                child: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.white),
                                  onPressed: () {
                                    // Handle delete button press here
                                    handleDeleteAction(album.id);
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('${snapshot.error}'),
                  );
                }

                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trending',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Container(
                          width: 150.0,
                          height: 225.0,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 76, 75, 77),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "Measuring programming progress by lines of code is like measuring aircraft building progress by weight.",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Actions',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Column(
                          children: [
                            Container(
                              width: 180.0,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 3, 91, 27),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 30,
                                  child: TextButton(
                                    onPressed: () {
                                      _uploadDialog();
                                    },
                                    child: Text(
                                      'Upload',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 25.0),
                            // Container(
                            //   width: 180.0,

                            //   decoration: BoxDecoration(
                            //     color: Color.fromARGB(255, 109, 40, 9),
                            //     borderRadius: BorderRadius.circular(15.0),
                            //   ),
                            //   child: Padding(
                            //     padding: const EdgeInsets.all(8.0),
                            //     child: SizedBox(
                            //       height: 30,
                            //       child: TextButton(
                            //         onPressed: () {
                            //           _deleteDialog();
                            //         },
                            //         child: Text(
                            //           'Delete',
                            //           style: TextStyle(
                            //             color: Colors.white,
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
