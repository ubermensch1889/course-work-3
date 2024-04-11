class DocumentItem {
  final String id;
  final String name;
  final bool signRequired;
  final String description;
  bool isSigned; // предполагаем, что поле может изменяться

  DocumentItem({
    required this.id,
    required this.name,
    required this.signRequired,
    required this.description,
    this.isSigned = false,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id'],
      name: json['name'],
      signRequired: json['sign_required'] as bool,
      description: json['description'],
      isSigned: json['is_signed'] as bool? ?? false,
    );
  }

  DocumentItem copyWith({bool? isSigned}) {
    return DocumentItem(
      id: id,
      name: name,
      signRequired: signRequired,
      description: description,
      isSigned: isSigned ?? this.isSigned,
    );
  }
}
