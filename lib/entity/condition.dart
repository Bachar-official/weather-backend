class Condition {
  final String text;
  final int code;

  const Condition({
    required this.code, required this.text
  });

  factory Condition.fromMap(Map<String, dynamic> map) => Condition(code: map['code'], text: map['text']);
}
