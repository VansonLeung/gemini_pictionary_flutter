
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:gemini_pictionary_flutter/components/ChatMessageList.dart';
import 'package:gemini_pictionary_flutter/providers/ChatMessageHistoryProvider.dart';
import 'package:gemini_pictionary_flutter/providers/ClientStatusProvider.dart';
import 'package:gemini_pictionary_flutter/providers/QuestionStatusProvider.dart';
import 'package:gemini_pictionary_flutter/repository/GeminiPictionaryWebsocketClient.dart';
import 'package:provider/provider.dart';

Uint8List dataFromBase64String(String base64String) {
  return base64Decode(base64String);
}

String base64String(Uint8List data) {
  return base64Encode(data);
}

class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({super.key});

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  late TextEditingController fAnswer;
  late ConfettiController _controllerCenter;

  @override
  void initState() {
    super.initState();
    fAnswer = TextEditingController(text: "");
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 5));
  }

  @override
  void dispose() {
    fAnswer.dispose();
    _controllerCenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final employeeProvider = Provider.of<QuestionStateProvider>(context, listen: false);
    employeeProvider.onAnswerSuccessStatusChange = (isSuccess, answer) {
      print("STATUS ${isSuccess} ${answer}");
      if (isSuccess) {
        _controllerCenter.play();
      }
    };

    return Scaffold(
      appBar: AppBar(
        title: Text("Gemini Pictionary"),
      ),
      body: Stack(children: [Column(
        children: [

          Consumer<ClientStatusProvider>(
              builder: (context, provider, _) {
                return Padding(padding: EdgeInsets.all(20), child: Row(
                  children: [
                    Expanded(child: Text( provider.meName() ?? "n/a" )),
                    Text( "Score: ${provider.meScore() ?? "--"}"  ),
                    ElevatedButton(onPressed: () {
                      GeminiPictionaryWebsocketClient.getInstance().gemGameLeave();
                    }, child: Text("Leave"))
                  ],
                ),);
              }
          ),

          Expanded(
            child: Consumer<QuestionStateProvider>(
                builder: (context, provider, _) {
                  return Row(
                      children: [
                        Expanded(
                          child: Center(child: Padding(padding: EdgeInsets.all(20), child: Column(
                            children: [
                              const Text("Guess what it is: "),
                              Text( provider.getQuestionDescription()?.join("\n\n") ?? "n/a")
                            ],
                          ),)),
                        ),

                        if (provider.getAnswer() != null)
                          Expanded(
                            child: Center(child: Column(
                              children: [
                                Text("Answer is ${provider.getAnswer() ?? "n/a"}"),

                                if (provider.getBase64ImageString() != null)
                                  Expanded(child:Image.memory(
                                    base64Decode(provider.getBase64ImageString()!),
                                    fit: BoxFit.contain,
                                  ))
                              ],
                            ),),
                          ),

                        if (provider.getAnswer() == null)
                          Expanded(
                            child: Center(child: Column(
                              children: [
                                if (provider.getBase64ImageString() != null)
                                  Expanded(child:
                                  ImageFiltered(
                                      imageFilter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                                      child: Image.memory(
                                        base64Decode(provider.getBase64ImageString()!),
                                        fit: BoxFit.contain,
                                      )))
                              ],
                            ),),
                          ),
                      ]
                  );
                }
            ),
          ),

          Expanded(
              child: Consumer<ChatMessageHistoryProvider>(
                builder: (context, messageProvider, _) {
                  return ChatMessageList(
                    messages: messageProvider.messages,
                  );
                },
              )

          ),

          Padding(padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40), child:
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: fAnswer,
                  decoration: const InputDecoration(
                    hintText: "Input your answer",
                  ),
                ),

              ),

              ElevatedButton(
                  onPressed: () {
                    GeminiPictionaryWebsocketClient.getInstance().gemAnswerSubmit(fAnswer.text);
                    fAnswer.text = "";
                  },
                  child: const Text("Start")
              ),

            ],
          ),
          ),
        ],
      ),
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _controllerCenter,
            blastDirection: -pi/2, // radial value - LEFT
            particleDrag: 0.01, // apply drag to the confetti
            emissionFrequency: 0.21, // how often it should emit
            numberOfParticles: 20, // number of particles to emit
            gravity: 1.0, // gravity - or fall speed
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink
            ], // manually specify the colors to be used
            strokeWidth: 1,
            strokeColor: Colors.white,
          ),
        ),

      ],
      ),
    );
  }
}
