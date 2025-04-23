import 'dart:convert';

class Question {
  final int? id;
  final int? categoryId;
  final String text;
  final String correctAnswer;
  final String options;
  final String? explanation;
  final String? imageUrl;

  Question({
    this.id,
    this.categoryId,
    required this.text,
    required this.correctAnswer,
    required this.options,
    this.explanation,
    this.imageUrl,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      categoryId: map['category_id'],
      text: map['question_text'],
      correctAnswer: map['correct_answer'],
      options: map['options'],
      explanation: map['explanation'],
      imageUrl: map['image_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'question_text': text,
      'correct_answer': correctAnswer,
      'options': options,
      'explanation': explanation,
      'image_url': imageUrl,
    };
  }

  Question copyWith({
    int? id,
    int? categoryId,
    String? text,
    String? correctAnswer,
    String? options,
    String? explanation,
    String? imageUrl,
  }) {

    return Question(
      // nếu id không null thì sử dụng id của đối tượng hiện tại, nếu null thì sử dụng id của đối tượng mới
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      text: text ?? this.text,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      options: options ?? this.options,
      explanation: explanation ?? this.explanation,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
