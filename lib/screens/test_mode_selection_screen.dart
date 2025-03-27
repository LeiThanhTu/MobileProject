import 'package:flutter/material.dart';
import 'review_mode_screen.dart';
import 'mock_test_screen.dart';

class TestModeSelectionScreen extends StatelessWidget {
  final int userId;

  const TestModeSelectionScreen({Key? key, required this.userId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn chế độ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildModeCard(
              context,
              title: 'Chế độ ôn tập',
              description: 'Ôn tập theo từng chủ đề, không giới hạn thời gian',
              icon: Icons.book,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewModeScreen(userId: userId),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildModeCard(
              context,
              title: 'Thi thử',
              description: 'Làm bài thi thử với thời gian giới hạn',
              icon: Icons.timer,
              onTap: () {
                _showMockTestSettings(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMockTestSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _MockTestSettingsSheet(userId: userId);
      },
    );
  }
}

class _MockTestSettingsSheet extends StatefulWidget {
  final int userId;

  const _MockTestSettingsSheet({Key? key, required this.userId})
    : super(key: key);

  @override
  _MockTestSettingsSheetState createState() => _MockTestSettingsSheetState();
}

class _MockTestSettingsSheetState extends State<_MockTestSettingsSheet> {
  int _questionCount = 30;
  int _timeInMinutes = 45;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Cài đặt bài thi',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Số câu hỏi'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _questionCount,
                      items:
                          [20, 30, 40, 50].map((count) {
                            return DropdownMenuItem(
                              value: count,
                              child: Text('$count câu'),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _questionCount = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Thời gian'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _timeInMinutes,
                      items:
                          [30, 45, 60, 90].map((time) {
                            return DropdownMenuItem(
                              value: time,
                              child: Text('$time phút'),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _timeInMinutes = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Đóng bottom sheet
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => MockTestScreen(
                        userId: widget.userId,
                        questionCount: _questionCount,
                        timeInMinutes: _timeInMinutes,
                      ),
                ),
              );
            },
            child: const Text('Bắt đầu thi'),
          ),
        ],
      ),
    );
  }
}
