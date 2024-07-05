class DocumentItem {
  final String id;
  final String name;
  final bool signRequired;
  final String description;
  bool isSigned;

  DocumentItem({
    required this.id,
    required this.name,
    required this.signRequired,
    required this.description,
    this.isSigned = false,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      signRequired: json['sign_required'] as bool? ?? false,
      isSigned: json['signed'] as bool? ?? false,
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
