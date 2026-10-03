import '../entities/study_document.dart';

abstract interface class DocumentRepository {
  Future<List<StudyDocument>> getAll();

  Future<StudyDocument> create(StudyDocument document);

  Future<void> update(StudyDocument document);

  Future<void> delete(String id);

  Future<void> toggleFavorite(String id);
}
