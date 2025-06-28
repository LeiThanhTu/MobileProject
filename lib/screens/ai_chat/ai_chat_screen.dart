import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test/models/chat_message.dart';
import 'package:test/services/ai_service.dart';
import 'package:test/widgets/chat_bubble.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({Key? key}) : super(key: key);

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _aiService = AIService();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _sendMessage() async {
    if (_textController.text.isEmpty) return;

    final userMessage = ChatMessage(
      text: _textController.text,
      type: ChatMessageType.user,
    );
    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _textController.clear();
    _scrollToBottom();

    try {
      final botResponse = await _aiService.sendMessage(userMessage.text);
      final aiMessage = ChatMessage(
        text: botResponse,
        type: ChatMessageType.bot,
      );
      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });
    } catch (e) {
      final errorMessage = ChatMessage(
        text:
            'Sorry, something went wrong. Please check your API key and network connection.',
        type: ChatMessageType.bot,
      );
      setState(() {
        _messages.add(errorMessage);
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Assistant',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  message: message.text,
                  isUser: message.type == ChatMessageType.user,
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 2,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                onSubmitted: (value) => _sendMessage(),
                enableIMEPersonalizedLearning: true,
                enableSuggestions: true,
                autocorrect: true,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.send,
                maxLines: null,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'^\s*$'),
                      replacementString: ''),
                ],
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn của bạn...',
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send_rounded),
              onPressed: _sendMessage,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
