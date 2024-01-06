// import 'dart:ffi';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<User>> fetchUsers() async {
  var client = http.Client();
  try {
    var uri = Uri.http('127.0.0.1:8000', '/get_users/');
    final response = await client.get(uri);
    if (response.statusCode == 200) {
      debugPrint('movieTitle: ${response.body}');
      List<dynamic> list = jsonDecode(response.body);
      return list
          .map((data) => User.fromJson(data as Map<String, dynamic>))
          .toList();
    } else {
      print("error");
      throw Exception('Failed to load users');
    }
  } catch (e) {
    print(e);

    throw Exception('Failed to load users: $e');
  }
}

class User {
  final int id;
  final String email;
  final String name;
  final String dateJoined;

  User(
      {required this.id,
      required this.email,
      required this.name,
      required this.dateJoined});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      dateJoined: json['date_joined'],
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Fairshare',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Color.fromARGB(255, 221, 146, 170)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add_a_photo_outlined),
          onPressed: () {
            print("presssed");
          }),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album),
            label: "Reciept Photos",
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Text("Faire Share"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified),
            Container(margin: EdgeInsets.all(20), child: Text("hello world")),
            TestWidget(appState: appState),
            ElevatedButton(
              onPressed: () {
                appState.getNext();
              },
              child: Text('Next'),
            ),
            FutureBuilder<List<User>>(
              future: fetchUsers(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('An error occurred ${snapshot.error}');
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        User user = snapshot.data![index];
                        return ListTile(
                          title: Text(user.name),
                          subtitle: Text(user.email),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TestWidget extends StatelessWidget {
  const TestWidget({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(appState.current.asUpperCase, style: style),
      ),
    );
  }
}
