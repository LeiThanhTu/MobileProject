import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test/database/database_helper.dart';
import 'package:confetti/confetti.dart';
import 'package:test/models/question_result.dart';
import 'package:test/screens/quizz/question_detail_screen.dart';
import 'package:test/services/ai_service.dart';

class ResultDetailScreen extends StatefulWidget {
  final int resultId;
  final String categoryName;
  final int score;
  final int totalQuestions;

  ResultDetailScreen({
    required this.resultId,
    required this.categoryName,
    required this.score,
    required this.totalQuestions,
  });

  @override
  _ResultDetailScreenState createState() => _ResultDetailScreenState();
}

class _ResultDetailScreenState extends State<ResultDetailScreen> {
  late ConfettiController _confettiController;
  late Future<List<QuestionResult>> _questionResultsFuture;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _questionResultsFuture = _dbHelper.getQuestionResults(widget.resultId);
    _confettiController = ConfettiController(duration: Duration(seconds: 5));

    if (widget.score / widget.totalQuestions >= 0.7) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.score / widget.totalQuestions * 100).round();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.indigo[600]),
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        title: Text(
          'Kết quả',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.indigo[800],
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildResultSummary(percentage),
                SizedBox(height: 30),
                Expanded(
                  child: FutureBuilder<List<QuestionResult>>(
                    future: _questionResultsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No question results found'));
                      } else {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final questionResult = snapshot.data![index];
                            return _buildQuestionResultItem(
                              questionResult,
                              index + 1,
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.2,
              colors: [
                Colors.indigo,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSummary(int percentage) {
    String resultMessage;
    Color resultColor;
    IconData resultIcon;

    if (percentage >= 80) {
      resultMessage = 'Excellent!';
      resultColor = Colors.green[600]!;
      resultIcon = Icons.emoji_events;
    } else if (percentage >= 60) {
      resultMessage = 'Good Job!';
      resultColor = Colors.blue[600]!;
      resultIcon = Icons.thumb_up;
    } else if (percentage >= 40) {
      resultMessage = 'Nice Try!';
      resultColor = Colors.orange[600]!;
      resultIcon = Icons.sentiment_satisfied;
    } else {
      resultMessage = 'Keep Practicing!';
      resultColor = Colors.red[600]!;
      resultIcon = Icons.school;
    }

    return Column(
      children: [
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(resultIcon, size: 32, color: resultColor),
                    SizedBox(width: 10),
                    Text(
                      resultMessage,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: resultColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  '${widget.categoryName} Quiz',
                  style: GoogleFonts.poppins(
                      fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 20),
                Text(
                  '$percentage%',
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: resultColor,
                  ),
                ),
                Text(
                  'Score: ${widget.score}/${widget.totalQuestions}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 20),
                LinearProgressIndicator(
                  value: widget.score / widget.totalQuestions,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(resultColor),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                SizedBox(height: 24),
                _AIFeedbackSection(
                  score: widget.score,
                  totalQuestions: widget.totalQuestions,
                  categoryName: widget.categoryName,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionResultItem(QuestionResult result, int questionNumber) {
    final isCorrect = result.userAnswer == result.correctAnswer;

    return FutureBuilder<String>(
      future: _dbHelper.getQuestionText(result.questionId),
      builder: (context, snapshot) {
        final questionText = snapshot.data ?? 'Loading question...';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuestionDetailScreen(
                  questionId: result.questionId,
                  userAnswer: result.userAnswer,
                  correctAnswer: result.correctAnswer,
                  questionIndex: questionNumber - 1,
                ),
              ),
            );
          },
          child: Card(
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: isCorrect ? Colors.green[50] : Colors.red[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color:
                              isCorrect ? Colors.green[100] : Colors.red[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            '$questionNumber',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: isCorrect
                                  ? Colors.green[800]
                                  : Colors.red[800],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              questionText,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: isCorrect
                                      ? Colors.green[600]
                                      : Colors.red[600],
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  isCorrect ? 'Đúng' : 'Sai',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: isCorrect
                                        ? Colors.green[600]
                                        : Colors.red[600],
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Widget hiển thị gợi ý AI
class _AIFeedbackSection extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final String categoryName;
  const _AIFeedbackSection(
      {Key? key,
      required this.score,
      required this.totalQuestions,
      required this.categoryName})
      : super(key: key);

  @override
  State<_AIFeedbackSection> createState() => _AIFeedbackSectionState();
}

class _AIFeedbackSectionState extends State<_AIFeedbackSection> {
  String? _aiFeedback;
  bool _loading = false;

  Future<void> _getAIFeedback() async {
    setState(() {
      _loading = true;
      _aiFeedback = null;
    });
    final aiService = AIService();
    final prompt =
        'Tôi vừa làm bài kiểm tra chủ đề "${widget.categoryName}" với kết quả ${widget.score}/${widget.totalQuestions}. Hãy nhận xét kết quả này và gợi ý giúp tôi nên học gì tiếp theo. Trả lời ngắn gọn, súc tích, bằng tiếng Việt.';
    final response = await aiService.sendMessage(prompt);
    setState(() {
      _aiFeedback = response;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _loading ? null : _getAIFeedback,
          icon: const Icon(Icons.psychology_rounded),
          label: const Text('🧠 Gợi ý từ AI'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo[600],
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (_aiFeedback != null)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigo.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.smart_toy_rounded,
                    color: Colors.indigo, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _aiFeedback!,
                    style: GoogleFonts.poppins(
                        fontSize: 15, color: Colors.indigo[900]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
