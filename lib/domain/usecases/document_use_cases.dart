import '../entities/study_document.dart';
import '../repositories/document_repository.dart';

class GetDocuments {
  const GetDocuments(this._repository);

  final DocumentRepository _repository;

  Future<List<StudyDocument>> call() => _repository.getAll();
}

class SearchDocuments {
  const SearchDocuments();

  List<StudyDocument> call(
    Iterable<StudyDocument> documents,
    String query,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return List.unmodifiable(documents);
    }

    return List.unmodifiable(
      documents.where((document) {
        return document.title.toLowerCase().contains(normalizedQuery) ||
            document.category.label.toLowerCase().contains(normalizedQuery) ||
            document.fileType.toLowerCase().contains(normalizedQuery) ||
            document.subject.toLowerCase().contains(normalizedQuery);
      }),
    );
  }
}

class CreateDocument {
  const CreateDocument(this._repository);

  final DocumentRepository _repository;

  Future<StudyDocument> call(StudyDocument document) {
    return _repository.create(document);
  }
}

class UpdateDocument {
  const UpdateDocument(this._repository);

  final DocumentRepository _repository;

  Future<void> call(StudyDocument document) => _repository.update(document);
}

class DeleteDocument {
  const DeleteDocument(this._repository);

  final DocumentRepository _repository;

  Future<void> call(String id) => _repository.delete(id);
}

class ToggleDocumentFavorite {
  const ToggleDocumentFavorite(this._repository);

  final DocumentRepository _repository;

  Future<void> call(String id) => _repository.toggleFavorite(id);
}
