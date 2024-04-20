import 'package:flutter/material.dart';
import 'package:gemini_pictionary_flutter/repository/GeminiPictionaryWebsocketClient.dart';

class ChatMessageList extends StatefulWidget {
  final List<GeminiPictionaryWebsocketResponseBundle> messages;

  const ChatMessageList({super.key, required this.messages});

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant ChatMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(widget.messages[index].getRepresentation()),
        );
      },
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 50), ()
      {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }
}