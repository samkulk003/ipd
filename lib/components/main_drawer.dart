import 'package:flutter/material.dart';
import 'package:ipd/components/comma.dart';
import 'package:ipd/components/exclamation.dart';
import 'package:ipd/components/fullstop.dart';
import 'package:ipd/components/AttractiveTestDisplay.dart';
import 'package:ipd/components/question_mark.dart';
import 'package:ipd/pages/homepage.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});
  // void _selectedpunctuation(BuildContext context) {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (ctx) => const Exclamation(),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drop & Drag'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: AttractiveTextDisplay(),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            const DrawerHeader(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Color.fromARGB(255, 1, 25, 66)],
                ),
              ),
              child: Row(children: [
                Icon(Icons.menu_book_sharp, size: 30),
                Text(
                  "Let's revise",
                  style: TextStyle(fontSize: 35),
                ),
              ]),
            ),
            ListTile(
              leading: const Icon(
                Icons.question_mark_outlined,
                color: Colors.red,
                size: 30,
              ),
              title: const Text(
                'Question Mark',
                //textAlign: TextAlign.left,
                style: TextStyle(fontSize: 25),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => QuestionScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.format_list_numbered),
              title: const Text(
                'Comma',
                style: TextStyle(fontSize: 24),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => CommaScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.sentiment_very_satisfied),
              title: const Text(
                'Exclamation Mark',
                style: TextStyle(fontSize: 24),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => ExclamationScreen(),
                  ),
                );

                // Handle the click action for the Exclamation Mark
              },
            ),
            ListTile(
                leading: const Icon(
                  Icons.circle_sharp,
                  color: Colors.black,
                  size: 12,
                ),
                title: const Text(
                  'Full Stop',
                  style: TextStyle(fontSize: 24),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => FullStopScreen(),
                    ),
                  );
                }),
            ListTile(
              leading: const Icon(
                Icons.home,
                color: Colors.black,
                size: 20,
              ),
              title: const Text(
                'Home Page',
                style: TextStyle(fontSize: 24),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => HomePage(),
                  ),
                );
                // Handle the click action for the Full Stop
              },
            ),
          ],
        ),
      ),
    );
  }
}
