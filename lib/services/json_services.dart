import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:quiz_game/models/questions_model.dart';

import '../models/category_model.dart';

class ReadJsonFiles {
  Future<List> readCategories() async {
    List categories = [];
    final String response =
        await rootBundle.loadString('assets/categories.json');
    final data = await json.decode(response);

    for (var category in data['category']) {
      Category categoryObj = Category(
        title: category['title'],
        id: category['id'],
      );
      categories.add(categoryObj);
    }

    return categories;
  }

  Future<List> readQuestions(String title) async {
    List questions = [];
    final String response =
        await rootBundle.loadString('assets/' + title.toLowerCase() + '.json');
    final data = await json.decode(response);

    for (var question in data['questions']) {
      Questions questionsObj = Questions(
          question: question['question'],
          answer1: question['answer1'],
          answer2: question['answer2'],
          answer3: question['answer3'],
          answer4: question['answer4'],
          correctAnswer: question['correctAnswer'], id: question['id']);
      questions.add(questionsObj);
    }

    return questions;
  }
}
