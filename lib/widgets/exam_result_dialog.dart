import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test/screens/results/result_screen.dart';

class ExamResultDialog extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;

  const ExamResultDialog({
    Key? key,
    required this.correctAnswers,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final score = (correctAnswers / totalQuestions) * 10;
    final isPass = score >= 5.0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kết quả bài thi',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[800],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isPass ? Colors.green[50] : Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${score.toStringAsFixed(1)}/10',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isPass ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      '$correctAnswers câu đúng',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isPass ? 'Chúc mừng bạn đã hoàn thành!' : 'Cố gắng lần sau nhé!',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isPass ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPass ? Icons.emoji_events : Icons.stars,
                  color: isPass ? Colors.amber : Colors.grey[400],
                  size: 32,
                ),
                const SizedBox(width: 8),
                Text(
                  isPass ? 'Xuất sắc!' : 'Tiếp tục cố gắng!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isPass ? Colors.amber[700] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context, rootNavigator: true).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => ResultsScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[800],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Đóng',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
