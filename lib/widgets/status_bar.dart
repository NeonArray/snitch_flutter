import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  final bool paused;

  const StatusBar({super.key, required this.paused});

  @override
  Widget build(BuildContext context) {
    var status = paused ? "Refusing" : "Accepting";
    var style = const TextStyle(
      color: Colors.black,
      fontSize: 12,
    );
    return Container(
      decoration: BoxDecoration(
        color: paused ? Colors.redAccent : Colors.green,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      height: 25,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$status connections",
            style: style,
          ),
          Text(
            "Listening on localhost:9999",
            style: style,
          ),
        ],
      ),
    );
  }
}
