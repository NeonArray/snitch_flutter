class Origin {
  String? file;
  int? lineNumber;
  String? hostname;

  Origin(this.file, this.lineNumber, this.hostname);

  factory Origin.fromJson(Map<String, dynamic> json) {
    return Origin(
      json['file'],
      json['line_number'],
      json['hostname'],
    );
  }
}
