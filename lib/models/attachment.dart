class Attachment {
  final String id;
  final String uri;

  Attachment({required this.id, required this.uri});

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(id: json['id'], uri: json['uri']);
  }
}
