import 'package:sqflite/sqflite.dart';

import '../../domain/entities/study_document.dart';
import '../../domain/repositories/document_repository.dart';

class SqliteDocumentRepository implements DocumentRepository {
  const SqliteDocumentRepository(this._database);

  final Database _database;

  @override
  Future<List<StudyDocument>> getAll() async {
    final rows = await _database.query(
      'study_documents',
      orderBy: 'created_at DESC, rowid DESC',
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<StudyDocument> create(StudyDocument document) async {
    final savedDocument = document.copyWith(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
    );
    await _database.insert('study_documents', _toRow(savedDocument));
    return savedDocument;
  }

  @override
  Future<void> update(StudyDocument document) async {
    final updatedRows = await _database.update(
      'study_documents',
      _toRow(document),
      where: 'id = ?',
      whereArgs: [document.id],
    );
    if (updatedRows == 0) {
      throw StateError('Không tìm thấy tài liệu để cập nhật.');
    }
  }

  @override
  Future<void> delete(String id) async {
    final deletedRows = await _database.delete(
      'study_documents',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedRows == 0) {
      throw StateError('Không tìm thấy tài liệu để xóa.');
    }
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final rows = await _database.query(
      'study_documents',
      columns: ['is_favorite'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw StateError('Không tìm thấy tài liệu để cập nhật yêu thích.');
    }

    final currentValue = rows.single['is_favorite'] as int;
    await _database.update(
      'study_documents',
      {'is_favorite': currentValue == 0 ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  StudyDocument _fromRow(Map<String, Object?> row) {
    return StudyDocument(
      id: row['id']! as String,
      title: row['title']! as String,
      subject: row['subject']! as String,
      category: StudyDocumentCategoryX.fromName(row['category']! as String),
      description: row['description']! as String,
      fileType: row['file_type']! as String,
      resourceLocation: row['resource_location']! as String,
      createdAt: DateTime.parse(row['created_at']! as String),
      isFavorite: row['is_favorite'] == 1,
    );
  }

  Map<String, Object?> _toRow(StudyDocument document) {
    return {
      'id': document.id,
      'title': document.title,
      'subject': document.subject,
      'category': document.category.name,
      'description': document.description,
      'file_type': document.fileType,
      'resource_location': document.resourceLocation,
      'created_at': document.createdAt.toIso8601String(),
      'is_favorite': document.isFavorite ? 1 : 0,
    };
  }
}
