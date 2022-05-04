import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../services.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  // Future<void> readJson() async {
  //   final String response = await rootBundle.loadString('assets/science_questions.json');
  //   final data = await json.decode(response);
  //   print(data['category'][0]);
  // }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    //final provider = Provider.of<GoogleSignInProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: SizedBox(
        width: screenWidth * 1,
        height: screenHeight * 1,
      )),
    );
  }

  Widget googleSignInButton(screenWidth, screenHeight) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasData) {
              return Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  width: screenWidth * 0.3,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.transparent),
                    ),
                    onPressed: () {
                      // provider.logOut();
                    },
                    child: SizedBox(
                      width: screenWidth * 0.3,
                      height: screenHeight * 0.025,
                      child: const FittedBox(
                        child: Text('Sign out',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: SizedBox(
                        height: screenHeight * 0.055,
                        child: FittedBox(
                          child: ElevatedButton.icon(
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(5),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.blue.shade400.withOpacity(1)),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ))),
                            onPressed: () {
                              //  provider.googleLogin();
                            },
                            label: const Text(
                              'Sign in with Google',
                              style: TextStyle(color: Colors.black),
                            ),
                            icon: const FaIcon(
                              FontAwesomeIcons.google,
                              size: 20,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          }
        });
  }
}
