import 'origin.dart';

class Block {
  final Origin origin;
  final String language;
  final String? code;
  final String? command;
  final DateTime time = DateTime.now();

  Block(this.origin, this.language, this.code, this.command);

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      Origin.fromJson(json['origin']),
      json['language'],
      json['value'],
      json['command'],
    );
  }
}
