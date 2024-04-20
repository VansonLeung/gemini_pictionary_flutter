
import 'package:flutter/material.dart';
import 'package:gemini_pictionary_flutter/repository/GeminiPictionaryWebsocketClient.dart';

class ClientStatusProvider extends ChangeNotifier {

  GeminiPictionaryWebsocketResponseBundle? _bundle;

  GeminiPictionaryWebsocketResponseBundle? get bundle => _bundle;

  void setClient(GeminiPictionaryWebsocketResponseBundle? bundle) {
    _bundle = bundle;
    notifyListeners();
  }

  String? meName() {
    return _bundle?.responseMap?["client"]["name"] ?? "";
  }

  String? meScore() {
    return "${_bundle?.responseMap?["client"]["score"] ?? "--"}";
  }
}