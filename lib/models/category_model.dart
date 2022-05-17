import 'package:flutter/foundation.dart';

class Category{
  String id;
  String title;
  int highScore=0;

  Category({required this.id, required this.title, highScore});

  factory Category.fromJson(Map json) {
    return Category(
        title: json['title'],
        id: json['id'],
        highScore: json['highScore'],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'id':id,
    'highScore':highScore
  };

}