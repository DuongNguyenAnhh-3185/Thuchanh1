enum StudyDocumentCategory {
  lecture,
  assignment,
  reference,
}

extension StudyDocumentCategoryX on StudyDocumentCategory {
  String get label {
    switch (this) {
      case StudyDocumentCategory.lecture:
        return 'Bài giảng';
      case StudyDocumentCategory.assignment:
        return 'Bài tập';
      case StudyDocumentCategory.reference:
        return 'Tài liệu tham khảo';
    }
  }

  static StudyDocumentCategory fromName(String name) {
    return StudyDocumentCategory.values.firstWhere(
      (category) => category.name == name,
    );
  }
}

class StudyDocument {
  const StudyDocument({
    required this.id,
    required this.title,
    required this.subject,
    required this.category,
    required this.description,
    required this.fileType,
    required this.resourceLocation,
    required this.createdAt,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String subject;
  final StudyDocumentCategory category;
  final String description;
  final String fileType;
  final String resourceLocation;
  final DateTime createdAt;
  final bool isFavorite;

  StudyDocument copyWith({
    String? id,
    String? title,
    String? subject,
    StudyDocumentCategory? category,
    String? description,
    String? fileType,
    String? resourceLocation,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return StudyDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      category: category ?? this.category,
      description: description ?? this.description,
      fileType: fileType ?? this.fileType,
      resourceLocation: resourceLocation ?? this.resourceLocation,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
