import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quiz_game/models/category_model.dart';
import '../services/json_services.dart';
import '../services/shared_prefs.dart';

class Questions extends StatefulWidget {
  final Category element;

  const Questions(this.element, {Key? key}) : super(key: key);

  @override
  State<Questions> createState() => _QuestionsState();
}

class _QuestionsState extends State<Questions> with TickerProviderStateMixin {
  ReadJsonFiles readJsonFiles = ReadJsonFiles();
  List questions = [];
  int questionIndex = 0;
  int buttonIndex = 0;
  int failedToAnswerCorrectIndex = 0;
  bool isPressed = false;
  Color resultColor = Colors.black;
  double timer = 10;
  bool timerIsActive = false;
  Timer? _timer;
  Color progressBarColor = Colors.purple;
  late Color timerColor;
  late AnimationController controller;
  String resultText = '';
  int correctAnswersCounter = 0;
  bool completed = false;
  SharedPrefsServices prefs = SharedPrefsServices();
  int categoryHighScore = 0;

  @override
  void initState() {
    getPrefs();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )
      ..addStatusListener((AnimationStatus status) {
        setState(() {});
      })
      ..addListener(() {
        setState(() {});
      });
    readJsonFiles.readQuestions(widget.element.title).then((value) {
      setState(() {
        questions.addAll(value);
        questions.shuffle();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    if (timer <= 2) {
      progressBarColor = const Color.fromRGBO(247, 23, 70, 1);
    } else if (timer <= 4) {
      progressBarColor = const Color.fromRGBO(226, 27, 34, 1);
    } else if (timer <= 6) {
      progressBarColor = const Color.fromRGBO(202, 58, 176, 1);
    } else if (timer <= 8) {
      progressBarColor = const Color.fromRGBO(145, 56, 167, 1);
    } else {
      progressBarColor = const Color.fromRGBO(105, 32, 142, 1);
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: questions.isNotEmpty
              ? SizedBox(
                  width: screenWidth * 1,
                  height: screenHeight * 1,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          questionNumber(screenWidth, screenHeight),
                          SizedBox(
                            height: screenHeight * 0.04,
                          ),
                          progressBar(screenWidth, screenHeight),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: screenHeight * 0.05,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 50, left: 20.0, bottom: 40),
                            child: SizedBox(
                              width: screenWidth * 0.9,
                              //height: screenHeight*0.03,
                              child: Text(
                                questions[questionIndex].question,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 22,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.02,
                          ),
                          Center(
                            child: Wrap(
                              runSpacing: 10,
                              children: [
                                answerButton(1, questions[questionIndex].answer1,
                                    screenWidth, screenHeight),
                                answerButton(2, questions[questionIndex].answer2,
                                    screenWidth, screenHeight),
                                answerButton(3, questions[questionIndex].answer3,
                                    screenWidth, screenHeight),
                                answerButton(4, questions[questionIndex].answer4,
                                    screenWidth, screenHeight),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.2,
                          ),
                          SizedBox(
                            height: screenHeight * 0.06,
                            child: endGameButton(screenWidth, screenHeight),
                          ),
                        ],
                      ),
                      completed
                          ? Center(
                              child: SizedBox(
                                height: screenHeight * 0.4,
                                child: scoreWindow(screenHeight, screenWidth),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }

  Widget answerButton(index, answer, screenWidth, screenHeight) {
    return SizedBox(
      width: screenWidth * 0.9,
      height: screenHeight * 0.06,
      child: ElevatedButton(
        style: ButtonStyle(
            elevation: MaterialStateProperty.all(5),
            backgroundColor:
                MaterialStateProperty.all<Color>(buttonIndex == index
                    ? resultColor
                    : failedToAnswerCorrectIndex == index
                        ? Colors.blue
                        : Colors.white),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                    side: const BorderSide(
                        color: Color.fromRGBO(84, 90, 117, 1), width: 1)))),
        onPressed: () {
          _timer?.cancel();
          isPressed
              ? null
              : setState(() {
                  buttonIndex = index;
                });
          isPressed ? null : checkAnswerValidity(answer);
        },
        child: SizedBox(
          width: screenWidth * 0.8,
          height: screenHeight * 0.03,
          child: FittedBox(
              child: Text(
            answer,
            style: const TextStyle(color: Colors.black),
          )),
        ),
      ),
    );
  }

  void checkAnswerValidity(String answer) {
    controller.stop();
    if (answer == questions[questionIndex].correctAnswer) {
      resultText = 'Correct!';
      resultColor = Colors.green;
      correctAnswersCounter++;
      if (correctAnswersCounter > categoryHighScore) {
        setState(() {
          categoryHighScore = correctAnswersCounter;
        });
        savePrefs();
      }
    } else {
      resultText = 'Wrong!';
      resultColor = Colors.red;
      if (questions[questionIndex].answer1 ==
          questions[questionIndex].correctAnswer) {
        failedToAnswerCorrectIndex = 1;
      } else if (questions[questionIndex].answer2 ==
          questions[questionIndex].correctAnswer) {
        failedToAnswerCorrectIndex = 2;
      } else if (questions[questionIndex].answer3 ==
          questions[questionIndex].correctAnswer) {
        failedToAnswerCorrectIndex = 3;
      } else {
        failedToAnswerCorrectIndex = 4;
      }
    }
    if (questionIndex == questions.length - 1) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            completed = true;
          });
        }
      });
    } else {
      incrementQuestionIndex();
    }
    if (mounted) {
      setState(() {
        isPressed = true;
      });
    }
  }

  void incrementQuestionIndex() {
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        if (completed == false) {
          setState(() {
            resultColor = Colors.black;
            isPressed = false;
            buttonIndex = 0;
            failedToAnswerCorrectIndex = 0;
            questionIndex++;
            timer = 10;
            startTimer();
            controller.reset();
            controller.forward();
            resultText = '';
          });
        }
      }
    });
  }

  Widget getTimer() {
    if (timerIsActive) {
    } else {
      controller.forward();
      startTimer();
      if (mounted) {
        setState(() {
          timerIsActive = true;
        });
      }
    }
    timer == 0 ? checkAnswerValidity('') : null;
    return timer > 0
        ? Stack(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Icon(
                    Icons.access_time_rounded,
                    color: Colors.black,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  timer.round().toString(),
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),
            ],
          )
        : const Align(
            alignment: Alignment.center,
            child: Text(
              'Time is up!',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          );
  }

  void startTimer() {
    if (mounted) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (timer > 0) {
          if (mounted) {
            setState(() {
              timer--;
            });
          }
        } else {
          _timer?.cancel();
        }
      });
    }
  }

  Widget scoreWindow(screenHeight, screenWidth) {
    _timer?.cancel();
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      elevation: 10,
      title: const Text('Congratulations!'),
      content: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
                "You scored $correctAnswersCounter out of ${questions.length.toString()} in the ${widget.element.title} category."),
            categoryHighScore < correctAnswersCounter
                ? Text(
                    'New High Score!',
                    style: TextStyle(color: Colors.amber[900]),
                  )
                : Text('High score: $categoryHighScore',
                    style: TextStyle(color: Colors.amber[900]))
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ButtonStyle(
              elevation: MaterialStateProperty.all(5),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ))),
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
          child: const Text('Back to menu'),
        ),
      ],
    );
  }

  void getPrefs() {
    prefs.getNamedPreference(widget.element.title).then((value) {
      if (value.isNotEmpty) {
        categoryHighScore = value['highScore'];
      }
    });
  }

  void savePrefs() {
    Map highScoreMap = {
      "highScore": categoryHighScore,
    };
    prefs.saveNamedPreference(highScoreMap, widget.element.title);
  }

  questionNumber(double screenWidth, double screenHeight) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 25.0, top: 20),
        child: SizedBox(
          height: screenHeight * 0.03,
          child: FittedBox(
              child: Text(
            'Question ${questionIndex + 1}/${questions.length}',
            style: const TextStyle(color: Colors.black),
          )),
        ),
      ),
    );
  }

  progressBar(double screenWidth, double screenHeight) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 20.0, right: 20),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(32)),
            border: Border.all(
                color: const Color.fromRGBO(84, 90, 117, 1), width: 1)),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(32)),
          child: SizedBox(
            height: screenHeight * 0.04,
            child: Stack(
              children: [
                LinearProgressIndicator(
                  minHeight: screenHeight * 0.04,
                  backgroundColor: Colors.transparent,
                  color: progressBarColor,
                  value: controller.value,
                ),
                getTimer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  endGameButton(double screenWidth, double screenHeight) {
    return FittedBox(
      child: ElevatedButton(
        style: ButtonStyle(
            elevation: MaterialStateProperty.all(5),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Colors.black),
              borderRadius: BorderRadius.circular(32),
            ))),
        onPressed: () {
          controller.stop();
          _timer?.cancel();
          setState(() {
            completed = true;
          });
        },
        child: const Text(
          'END GAME',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
