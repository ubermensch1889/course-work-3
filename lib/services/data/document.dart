class DocumentItem {
  final String id;
  final String name;
  final bool signRequired;
  final String description;

  DocumentItem({
    required this.id,
    required this.name,
    required this.signRequired,
    required this.description,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id'],
      name: json['name'],
      signRequired: json['sign_required'],
      description: json['description'] ?? '',
    );
  }
}
