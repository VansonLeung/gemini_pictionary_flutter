
import 'package:flutter/material.dart';
import 'package:gemini_pictionary_flutter/repository/GeminiPictionaryWebsocketClient.dart';

class QuestionStateProvider extends ChangeNotifier {

  GeminiPictionaryWebsocketResponseBundle? _bundle;
  String? _answer;

  GeminiPictionaryWebsocketResponseBundle? get bundle => _bundle;

  Function(bool, String?)? onAnswerSuccessStatusChange;

  void setQuestion(GeminiPictionaryWebsocketResponseBundle bundle) {
    _bundle = bundle;
    notifyListeners();
  }

  void setAnswer(String? answer) {
    if (_answer != answer) {
      _answer = answer;
      if (_answer != null) {
        onAnswerSuccessStatusChange?.call(true, _answer);
      } else {
        onAnswerSuccessStatusChange?.call(false, _answer);
      }
    }
    notifyListeners();
  }

  String? getAnswer() {
    return _answer;
  }

  String? getBase64ImageString() {
    return _bundle?.responseMap?["question_payload"]["base64_image"] as String?;
  }

  List<String>? getQuestionDescription() {
    return List<String>.from(_bundle?.responseMap?["question_payload"]["r_question_arr"] ?? []);
  }

  List<String>? getQuestionAnswer() {
    return List<String>.from(_bundle?.responseMap?["question_payload"]["r_answer_arr"] ?? []);
  }
}
