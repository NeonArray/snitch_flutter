import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'models/block.dart';
import 'widgets/code_block.dart';
import 'widgets/delete_block_button.dart';
import 'widgets/status_bar.dart';
import 'widgets/timestamp.dart';

void main() async {
  runApp(const SnitchApp());
}

class SnitchApp extends StatefulWidget {
  const SnitchApp({super.key});

  @override
  State<SnitchApp> createState() => _SnitchAppState();
}

class _SnitchAppState extends State<SnitchApp> {
  late ServerSocket _server;
  final List<Block> _data = [];
  final _scrollController = ScrollController();
  bool _paused = false;
  bool _newEvent = false;

  @override
  void initState() {
    super.initState();
    initSocket();
  }

  void initSocket() async {
    _server =
        await ServerSocket.bind(InternetAddress.anyIPv4, 9999, shared: true);
    _server.listen(handleClient);
  }

  void parseCommand(String command) {
    switch (command) {
      case "clear_all":
        setState(() {
          _data.clear();
        });
    }
  }

  void scrollToLastItem() {
    // WidgetsBinding is used here to ensure the current frames widgets are
    // laid out, so that our animateTo will see the latest list item.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  List<String>? processMessage(data) {
    String? lengthHeader = '';
    String jsonData = utf8.decode(data);
    List<String> decoded = [];
    RegExp messageLengthExp = RegExp(r"(\d+)|");

    while (true) {
      RegExpMatch? matches = messageLengthExp.firstMatch(jsonData);
      if (matches == null) {
        return null;
      }
      lengthHeader = matches.group(1);
      if (lengthHeader == null || lengthHeader.isEmpty) {
        decoded.add(jsonData);
        break;
      }
      var part = jsonData.substring(
        lengthHeader.length + 1,
        int.parse(lengthHeader) + lengthHeader.length + 1,
      );
      decoded.add(part);
      jsonData = jsonData.substring(
        int.parse(lengthHeader) + lengthHeader.length + 1,
      );
      if (jsonData.isEmpty) {
        break;
      }
    }
    return decoded;
  }

  void onMessage(dynamic data) {
    if (_paused) {
      return;
    }

    var messages = processMessage(data);
    if (messages == null) {
      return;
    }

    var blocks = messages.map((e) {
      dynamic j;
      try {
        j = jsonDecode(e);
        if (j['command'] != null) {
          parseCommand(j['command']);
          return null;
        }
        return Block.fromJson(j);
      } catch (error) {
        return Block.fromDefaults(e);
      }
    });

    setState(() {
      _data.addAll(blocks.whereType<Block>());
      _newEvent = true;
    });

    Timer(const Duration(seconds: 2), () {
      setState(() {
        _newEvent = false;
      });
    });

    scrollToLastItem();
  }

  void onError(er) {
    if (kDebugMode) {
      print("Client error $er");
    }
  }

  void onDone() {
    if (kDebugMode) {
      print("Client left");
    }
  }

  void handleClient(Socket client) {
    client.listen(
      onMessage,
      onError: onError,
      onDone: onDone,
    );
    client.close();
  }

  @override
  void dispose() {
    _server.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snitch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all<Color>(Colors.white),
          trackColor: MaterialStateProperty.all<Color>(Colors.grey),
        ),
        extensions: const <ThemeExtension<dynamic>>[
          DeleteBlockButtonTheme(
            iconColor: Colors.grey,
          ),
          TimestampTheme(
            background: Colors.black45,
            borderColor: Colors.grey,
            fontColor: Colors.white,
          ),
          CodeBlockTheme(
            background: Colors.black54,
            border: Border(
              bottom: BorderSide(
                color: Colors.white10,
                width: 1,
              ),
            ),
          ),
        ],
      ),
      home: Scaffold(
        backgroundColor: Colors.grey[900],
        body: Column(
          children: [
            _appControls(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 8,
                ),
                controller: _scrollController,
                itemCount: _data.length,
                itemBuilder: (BuildContext context, int index) {
                  final time =
                      _data[index].time.toIso8601String().substring(11, 19);
                  return IntrinsicHeight(
                    child: Container(
                      decoration: BoxDecoration(
                        // TODO: The list shifts after the border fades out, why?
                        border: Border.all(
                          color: _newEvent && _data.length == index + 1
                              ? Colors.green
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 0,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Theme.of(context)
                                    .extension<CodeBlockTheme>()!
                                    .border,
                                color: Colors.black45,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      DeleteBlockButton(callback: () {
                                        setState(() {
                                          _data.removeAt(index);
                                        });
                                      }),
                                      Timestamp(time: time),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: CodeBlock(
                              data: _data[index],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            StatusBar(paused: _paused),
          ],
        ),
      ),
    );
  }

  Widget _appControls() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 18,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _data.clear();
              });
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            tooltip: 'Clear all',
          ),
          IconButton(
            splashRadius: 1,
            selectedIcon: const Icon(
              Icons.pause,
              color: Colors.white,
            ),
            isSelected: _paused,
            onPressed: () {
              setState(() {
                _paused = !_paused;
              });
            },
            icon: const Icon(
              Icons.play_arrow,
              color: Colors.white,
            ),
            tooltip: _paused ? 'Accept Connections' : 'Pause Connections',
          ),
        ],
      ),
    );
  }
}
