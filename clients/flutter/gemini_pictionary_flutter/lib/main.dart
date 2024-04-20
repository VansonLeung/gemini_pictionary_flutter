import 'dart:html';

import 'package:flutter/material.dart';
import 'package:gemini_pictionary_flutter/pages/LoginPage.dart';
import 'package:gemini_pictionary_flutter/pages/PlaygroundPage.dart';
import 'package:gemini_pictionary_flutter/providers/ChatMessageHistoryProvider.dart';
import 'package:gemini_pictionary_flutter/providers/ClientStatusProvider.dart';
import 'package:gemini_pictionary_flutter/providers/QuestionStatusProvider.dart';
import 'package:gemini_pictionary_flutter/repository/GeminiPictionaryWebsocketClient.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ChatMessageHistoryProvider()),
          ChangeNotifierProvider(create: (context) => QuestionStateProvider()),
          ChangeNotifierProvider(create: (context) => ClientStatusProvider()),
        ],
        child: const HomePage(),
      ),
    );
  }
}




class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // GeminiPictionaryWebsocketClient.getInstance().connect((message) {
  // print("Recv message ${message}");
  // Provider.of<ChatMessageHistoryProvider>()
  // });
  //

  @override
  void initState() {
    super.initState();
    GeminiPictionaryWebsocketClient.getInstance().connect(
      messageHandler: (p0) {
        print(p0);
        context.read<ChatMessageHistoryProvider>().addMessage(p0);
      },
      questionStatusHandler: (p0) {
        print(p0);
        context.read<QuestionStateProvider>().setQuestion(p0);
        context.read<QuestionStateProvider>().setAnswer(null);
      },
      questionAnsweredCorrectlyHandler: (p0) {
        print(p0);
        context.read<QuestionStateProvider>().setAnswer(p0.getAnswer());
      },
      meJoinedHandler: (p0) {
        print(p0);
        context.read<ClientStatusProvider>().setClient(p0);
      },
      meLeftHandler: (p0) {
        print(p0);
        context.read<ClientStatusProvider>().setClient(null);
      },
    );
  }

  @override
  void dispose() {
    GeminiPictionaryWebsocketClient.getInstance().disconnect();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ClientStatusProvider>(
      builder: (context, provider, _) {
        if (provider.bundle != null) {
          return const PlaygroundPage();
        } else {
          return const LoginPage();
        }
      },
    );
    return const LoginPage();
  }
}

