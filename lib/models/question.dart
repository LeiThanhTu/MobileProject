import 'dart:convert';

class Question {
  final int? id;
  final int categoryId;
  final String questionText;
  final String correctAnswer;
  final List<String> options;
  final String? explanation;

  String get text => questionText;
  String get optionA => options[0];
  String get optionB => options[1];
  String get optionC => options[2];
  String get optionD => options[3];

  Question({
    this.id,
    required this.categoryId,
    required this.questionText,
    required this.correctAnswer,
    required this.options,
    this.explanation,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'question_text': questionText,
      'correct_answer': correctAnswer,
      'options': jsonEncode(options),
      'explanation': explanation,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      questionText: map['question_text'] as String,
      correctAnswer: map['correct_answer'] as String,
      options: List<String>.from(jsonDecode(map['options'] as String)),
      explanation: map['explanation'] as String?,
    );
  }

  Question copyWith({
    int? id,
    int? categoryId,
    String? questionText,
    String? correctAnswer,
    List<String>? options,
    String? explanation,
  }) {
    return Question(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      questionText: questionText ?? this.questionText,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      options: options ?? this.options,
      explanation: explanation ?? this.explanation,
    );
  }
}
