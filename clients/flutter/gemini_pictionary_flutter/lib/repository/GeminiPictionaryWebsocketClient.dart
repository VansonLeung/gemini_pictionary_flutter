
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class GeminiPictionaryWebsocketResponseBundle {
  String message = "";
  Map<String, dynamic>? responseMap;

  bool isRefreshQuestion() {
    if (responseMap?.containsKey("on") == true) {
      String on = responseMap?["on"] ?? "";
      if (on == "_refresh_question") {
        return true;
      }
    }
    return false;
  }

  bool isMeJoined() {
    if (responseMap?.containsKey("on") == true) {
      String on = responseMap?["on"] ?? "";
      if (on == "me_joined") {
        return true;
      }
    }
    return false;
  }

  bool isMeLeft() {
    if (responseMap?.containsKey("on") == true) {
      String on = responseMap?["on"] ?? "";
      if (on == "me_left") {
        return true;
      }
    }
    return false;
  }

  bool isMeAnswerSubmitCorrect() {
    if (responseMap?.containsKey("on") == true) {
      String on = responseMap?["on"] ?? "";
      if (on == "me_answer_success") {
        if (responseMap?.containsKey("client") == true) {
          String name = responseMap?["client"]["name"] ?? "n/a";
          String r_answer = responseMap?["r_answer"] ?? "--";
          int score_delta = responseMap?["score_delta"] ?? 0;
          bool isCorrect = score_delta > 0;
          if (isCorrect) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool isMeAnswerSubmitFailure() {
    if (responseMap?.containsKey("on") == true) {
      String on = responseMap?["on"] ?? "";
      if (on == "me_answer_failure") {
        if (responseMap?.containsKey("client") == true) {
          String name = responseMap?["client"]["name"] ?? "n/a";
          String r_answer = responseMap?["r_answer"] ?? "--";
          int score_delta = responseMap?["score_delta"] ?? 0;
          bool isCorrect = score_delta > 0;
          if (!isCorrect) {
            return true;
          }
        }
      }
    }
    return false;
  }

  String getAnswer() {
    if (responseMap?.containsKey("on") == true) {
      String on = responseMap?["on"] ?? "";
      if (on == "answer_submit") {
        if (responseMap?.containsKey("client") == true) {
          String name = responseMap?["client"]["name"] ?? "n/a";
          String r_answer = responseMap?["r_answer"] ?? "--";
          return r_answer;
        }
      }
    }
    return "--";
  }

  String getRepresentation() {
    if (responseMap?.containsKey("on") == true) {
      String on = responseMap?["on"] ?? "";
      if (on == "game_join") {
        if (responseMap?.containsKey("client") == true) {
          String name = responseMap?["client"]["name"] ?? "n/a";
          return "${name} has joined the game";
        }
      }
      if (on == "game_leave") {
        if (responseMap?.containsKey("client") == true) {
          String name = responseMap?["client"]["name"] ?? "n/a";
          return "${name} has left the game";
        }
      }
      if (on == "answer_submit") {
        if (responseMap?.containsKey("client") == true) {
          String name = responseMap?["client"]["name"] ?? "n/a";
          String r_answer = responseMap?["r_answer"] ?? "--";
          int score_delta = responseMap?["score_delta"] ?? 0;
          bool isCorrect = score_delta > 0;
          if (isCorrect) {
            return "${name}: `${r_answer}` is Correct! ";
          } else {
            return "${name}: `${r_answer}` is Incorrect. ";
          }
        }
      }
    }

    return message;
  }
}

class GeminiPictionaryWebsocketClient {
  static const String wsUrl = "wss://flutter-tom-ws.www.vanportdev.com:8763";

  static GeminiPictionaryWebsocketClient? _instance;

  factory GeminiPictionaryWebsocketClient.getInstance() {
    _instance ??= GeminiPictionaryWebsocketClient();
    return _instance!;
  }

  GeminiPictionaryWebsocketClient();

  WebSocketChannel? _channel;

  void connect({
    Function(GeminiPictionaryWebsocketResponseBundle)? messageHandler,
    Function(GeminiPictionaryWebsocketResponseBundle)? meJoinedHandler,
    Function(GeminiPictionaryWebsocketResponseBundle)? meLeftHandler,
    Function(GeminiPictionaryWebsocketResponseBundle)? questionStatusHandler,
    Function(GeminiPictionaryWebsocketResponseBundle)? questionAnsweredCorrectlyHandler,
  }) {
    disconnect();
    print("connect");
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _listenForMessages((message) {
      Map<String, dynamic>? responseMap = jsonDecode(message);
      GeminiPictionaryWebsocketResponseBundle bundle = GeminiPictionaryWebsocketResponseBundle();
      bundle.message = message;
      bundle.responseMap = responseMap;

      if (bundle.isRefreshQuestion()) {
        if (questionStatusHandler != null) {
          questionStatusHandler(bundle);
        }
      } else if (bundle.isMeJoined()) {
        if (meJoinedHandler != null) {
          meJoinedHandler(bundle);
        }
      } else if (bundle.isMeLeft()) {
        if (meLeftHandler != null) {
          meLeftHandler(bundle);
        }
      } else if (bundle.isMeAnswerSubmitCorrect()) {
      } else if (bundle.isMeAnswerSubmitFailure()) {
      } else {
        if (messageHandler != null) {
          messageHandler(bundle);
        }
      }

      if (bundle.isMeAnswerSubmitCorrect()) {
        if (questionAnsweredCorrectlyHandler != null) {
          questionAnsweredCorrectlyHandler(bundle);
        }
      }

    });
  }

  void disconnect() {
    print("disconnect");
    _channel?.sink.close();
    _channel = null;
  }

  void _sendMessage(String message) {
    print("sendMessage ${message}");
    _channel?.sink.add(message);
  }

  void _listenForMessages(Function(dynamic) messageHandler) {
    print("listenForMessage");
    _channel?.stream.listen(
          (message) => messageHandler(message),
      onError: (error) => print('Error: $error'),
      onDone: () => print('Connection closed'),
    );
  }






  /////////




  void gemGameJoin(String name) {
    _sendMessage(jsonEncode({
      "action": "game_join",
      "name": name,
    }));
  }

  void gemGameLeave() {
    _sendMessage(jsonEncode({
      "action": "game_leave",
    }));
  }

  void gemAnswerSubmit(String answer) {
    _sendMessage(jsonEncode({
      "action": "answer_submit",
      "answer": answer,
    }));
  }

  void gemGamePlayerList() {
    _sendMessage(jsonEncode({
      "action": "game_player_list",
    }));
  }



}
