
import 'package:flutter/material.dart';
import 'package:gemini_pictionary_flutter/components/ChatMessageList.dart';
import 'package:gemini_pictionary_flutter/providers/ChatMessageHistoryProvider.dart';
import 'package:gemini_pictionary_flutter/repository/GeminiPictionaryWebsocketClient.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController fName = TextEditingController(text: "");



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Center(
        child: Column(
            children: [

              Expanded(
                  child: Consumer<ChatMessageHistoryProvider>(
                    builder: (context, messageProvider, _) {
                      return ChatMessageList(
                        messages: messageProvider.messages,
                      );
                    },
                  )

              ),

              Expanded(
                child: Padding(padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
                  child: Row(
                    children: [
                      Expanded(child:
                      TextField(
                        controller: fName,
                        decoration: const InputDecoration(
                          hintText: "Input your nickname",
                        ),
                      ),
                      ),

                      ElevatedButton(
                          onPressed: () {
                            GeminiPictionaryWebsocketClient.getInstance().gemGameJoin(fName.text);
                          },
                          child: const Text("Start")
                      ),

                    ],
                  ),
                ),
              ),
            ]
        ),
      ),
    );
  }
}
