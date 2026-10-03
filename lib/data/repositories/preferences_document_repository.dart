import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/study_document.dart';
import '../../domain/repositories/document_repository.dart';

class PreferencesDocumentRepository implements DocumentRepository {
  PreferencesDocumentRepository(this._preferences);

  static const _storageKey = 'cashew_study_documents';

  final SharedPreferences _preferences;
  Future<void>? _initialization;

  Future<void> _ensureInitialized() {
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    final storedValue = _preferences.getString(_storageKey);
    if (storedValue != null) {
      return;
    }
    await _save(_sampleDocuments);
  }

  @override
  Future<List<StudyDocument>> getAll() async {
    await _ensureInitialized();
    final storedValue = _preferences.getString(_storageKey);
    if (storedValue == null) {
      throw StateError('Không tìm thấy dữ liệu tài liệu đã lưu.');
    }
    final decoded = jsonDecode(storedValue) as List<dynamic>;
    return decoded
        .map((item) => _fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
  }

  @override
  Future<StudyDocument> create(StudyDocument document) async {
    final documents = await getAll();
    final savedDocument = document.copyWith(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
    );
    await _save([savedDocument, ...documents]);
    return savedDocument;
  }

  @override
  Future<void> update(StudyDocument document) async {
    final documents = await getAll();
    final index = documents.indexWhere((item) => item.id == document.id);
    if (index == -1) {
      throw StateError('Không tìm thấy tài liệu để cập nhật.');
    }
    final updated = [...documents];
    updated[index] = document;
    await _save(updated);
  }

  @override
  Future<void> delete(String id) async {
    final documents = await getAll();
    final remaining = documents.where((item) => item.id != id).toList();
    if (remaining.length == documents.length) {
      throw StateError('Không tìm thấy tài liệu để xóa.');
    }
    await _save(remaining);
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final documents = await getAll();
    final index = documents.indexWhere((item) => item.id == id);
    if (index == -1) {
      throw StateError('Không tìm thấy tài liệu để cập nhật yêu thích.');
    }
    final updated = [...documents];
    updated[index] = updated[index].copyWith(
      isFavorite: !updated[index].isFavorite,
    );
    await _save(updated);
  }

  Future<void> _save(List<StudyDocument> documents) {
    return _preferences.setString(
      _storageKey,
      jsonEncode(documents.map(_toJson).toList(growable: false)),
    );
  }

  StudyDocument _fromJson(Map<String, dynamic> json) {
    return StudyDocument(
      id: json['id'] as String,
      title: json['title'] as String,
      subject: json['subject'] as String,
      category: StudyDocumentCategoryX.fromName(json['category'] as String),
      description: json['description'] as String,
      fileType: json['fileType'] as String,
      resourceLocation: json['resourceLocation'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isFavorite: json['isFavorite'] as bool,
    );
  }

  Map<String, Object> _toJson(StudyDocument document) {
    return {
      'id': document.id,
      'title': document.title,
      'subject': document.subject,
      'category': document.category.name,
      'description': document.description,
      'fileType': document.fileType,
      'resourceLocation': document.resourceLocation,
      'createdAt': document.createdAt.toIso8601String(),
      'isFavorite': document.isFavorite,
    };
  }

  static final List<StudyDocument> _sampleDocuments = [
    StudyDocument(
      id: 'doc-1',
      title: 'Giới thiệu về Cấu trúc dữ liệu',
      subject: 'Kỹ thuật phần mềm',
      category: StudyDocumentCategory.lecture,
      description: 'Bài giảng tổng quan về cấu trúc dữ liệu và ứng dụng trong lập trình.',
      fileType: 'PDF',
      resourceLocation: '',
      createdAt: DateTime(2024, 9, 5),
      isFavorite: true,
    ),
    StudyDocument(
      id: 'doc-2',
      title: 'Bài tập tuần 3: Cây nhị phân',
      subject: 'Cấu trúc dữ liệu',
      category: StudyDocumentCategory.assignment,
      description:
          'Tập hợp các bài tập thực hành về cây nhị phân, đệ quy và duyệt cây.',
      fileType: 'DOCX',
      resourceLocation: '',
      createdAt: DateTime(2024, 9, 8),
    ),
    StudyDocument(
      id: 'doc-3',
      title: 'Tài liệu chuẩn OOP trong Java',
      subject: 'Lập trình hướng đối tượng',
      category: StudyDocumentCategory.reference,
      description: 'Tài liệu tham khảo chính thức về nguyên lý OOP và cách xây dựng mô hình lớp.',
      fileType: 'PDF',
      resourceLocation: '',
      createdAt: DateTime(2024, 9, 12),
    ),
    StudyDocument(
      id: 'doc-4',
      title: 'Slide hệ điều hành',
      subject: 'Hệ điều hành',
      category: StudyDocumentCategory.lecture,
      description: 'Tổng hợp slide về tiến trình, bộ nhớ và lập lịch.',
      fileType: 'PPTX',
      resourceLocation: '',
      createdAt: DateTime(2024, 9, 15),
    ),
  ];
}
