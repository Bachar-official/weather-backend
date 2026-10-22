class Holiday {
  final String text;

  const Holiday(this.text);

  factory Holiday.fromJson(Map<String, dynamic> json) => Holiday(json['text']);

  Map<String, dynamic> toJson() => {'text': text};

  @override
  String toString() => 'Holiday $text';
}