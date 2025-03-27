class Question {
  final int? id;
  final int categoryId;
  final String text;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption;
  final String explanation;
  final String correctAnswer;

  Question({
    this.id,
    required this.text,
    required this.categoryId,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
    required this.explanation,
    required this.correctAnswer,
    
  });

  Map toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'question': question,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'correctOption': correctOption,
      'explanation': explanation,
    };
  }

  factory Question.fromMap(Map map) {
    return Question(
      id: map['id'],
      categoryId: map['categoryId'],
      question: map['question'],
      optionA: map['optionA'],
      optionB: map['optionB'],
      optionC: map['optionC'],
      optionD: map['optionD'],
      correctOption: map['correctOption'],
      explanation: map['explanation'],
      correctAnswer: map['correctAnswer'],
      text: map['text'],
    );
  }
}