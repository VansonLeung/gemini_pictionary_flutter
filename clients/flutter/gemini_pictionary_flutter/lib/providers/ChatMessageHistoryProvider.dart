
import 'package:flutter/material.dart';
import 'package:gemini_pictionary_flutter/repository/GeminiPictionaryWebsocketClient.dart';

class ChatMessageHistoryProvider extends ChangeNotifier {

  List<GeminiPictionaryWebsocketResponseBundle> _messages = [];

  List<GeminiPictionaryWebsocketResponseBundle> get messages => _messages;

  void addMessage(GeminiPictionaryWebsocketResponseBundle message) {
    _messages.add(message);
    notifyListeners();
  }
}