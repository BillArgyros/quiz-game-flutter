import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quiz_game/screens/questions_screen.dart';
import 'package:quiz_game/services/json_services.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ReadJsonFiles readJsonFiles = ReadJsonFiles();
  List categories = [];

  @override
  void initState() {
    readJsonFiles.readCategories().then((value) {
      setState(() {
        categories.addAll(value);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: categories.isNotEmpty
            ? Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30.0, top: 30),
                      child: SizedBox(
                          width: screenWidth * 0.4,
                          height: screenHeight * 0.2,
                          child: const FittedBox(child: Text("Let's Play!"))),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      child: getCategories(screenWidth, screenHeight),
                    ),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  getCategories(double screenWidth, double screenHeight) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories
          .map<Widget>(
              (element) => categoryButton(screenWidth, screenHeight, element))
          .toList(),
    );
  }

  categoryButton(double screenWidth, double screenHeight, element) {
    return SizedBox(
      width: screenWidth * 0.9,
      height: screenHeight * 0.06,
      child: ElevatedButton(
        style: ButtonStyle(
            elevation: MaterialStateProperty.all(5),
            backgroundColor: MaterialStateProperty.all<Color>(
              Colors.white,
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                    side: const BorderSide(
                        color: Color.fromRGBO(84, 90, 117, 1), width: 1)))),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Questions(element)),
          );
        },
        child: SizedBox(
            width: screenWidth * 0.4,
            height: screenHeight * 0.03,
            child: FittedBox(
                child: Text(
              element.title,
              style: const TextStyle(color: Colors.black),
            ))),
      ),
    );
  }
}
