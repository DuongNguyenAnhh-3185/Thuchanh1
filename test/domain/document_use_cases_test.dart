import 'package:flutter_test/flutter_test.dart';
import 'package:lab_01/domain/entities/study_document.dart';
import 'package:lab_01/domain/repositories/document_repository.dart';
import 'package:lab_01/domain/usecases/document_use_cases.dart';

void main() {
  group('SearchDocuments', () {
    const search = SearchDocuments();
    final documents = [
      _document(
        id: 'lecture',
        title: 'Flutter cơ bản',
        category: StudyDocumentCategory.lecture,
        fileType: 'PDF',
        subject: 'Lập trình ứng dụng',
      ),
      _document(
        id: 'assignment',
        title: 'Bài thực hành',
        category: StudyDocumentCategory.assignment,
        fileType: 'DOCX',
        subject: 'Cơ sở dữ liệu',
      ),
    ];

    test('matches title, category, file type, and subject', () {
      expect(search(documents, 'FLUTTER').map((item) => item.id), ['lecture']);
      expect(search(documents, 'bài tập').map((item) => item.id), [
        'assignment',
      ]);
      expect(search(documents, 'docx').map((item) => item.id), ['assignment']);
      expect(search(documents, 'ứng dụng').map((item) => item.id), ['lecture']);
    });

    test('trims whitespace and returns all documents for an empty query', () {
      expect(search(documents, '  PDF  ').map((item) => item.id), ['lecture']);
      expect(search(documents, '   '), hasLength(2));
    });

    test('returns no results for an unmatched query', () {
      expect(search(documents, 'not found'), isEmpty);
    });
  });

  test(
    'CRUD and favorite use cases delegate to the repository contract',
    () async {
      final repository = _RecordingDocumentRepository();
      final document = _document(
        id: 'domain-test',
        title: 'Domain test',
        category: StudyDocumentCategory.reference,
        fileType: 'PDF',
        subject: 'Architecture',
      );

      expect((await GetDocuments(repository)()).single.id, document.id);
      expect((await CreateDocument(repository)(document)).id, document.id);
      await UpdateDocument(repository)(document);
      await DeleteDocument(repository)(document.id);
      await ToggleDocumentFavorite(repository)(document.id);

      expect(repository.calls, [
        'getAll',
        'create:${document.id}',
        'update:${document.id}',
        'delete:${document.id}',
        'favorite:${document.id}',
      ]);
    },
  );
}

StudyDocument _document({
  required String id,
  required String title,
  required StudyDocumentCategory category,
  required String fileType,
  required String subject,
}) {
  return StudyDocument(
    id: id,
    title: title,
    subject: subject,
    category: category,
    description: '',
    fileType: fileType,
    resourceLocation: '',
    createdAt: DateTime(2026),
  );
}

class _RecordingDocumentRepository implements DocumentRepository {
  final calls = <String>[];

  @override
  Future<List<StudyDocument>> getAll() async {
    calls.add('getAll');
    return [
      _document(
        id: 'domain-test',
        title: 'Domain test',
        category: StudyDocumentCategory.reference,
        fileType: 'PDF',
        subject: 'Architecture',
      ),
    ];
  }

  @override
  Future<StudyDocument> create(StudyDocument document) async {
    calls.add('create:${document.id}');
    return document;
  }

  @override
  Future<void> update(StudyDocument document) async {
    calls.add('update:${document.id}');
  }

  @override
  Future<void> delete(String id) async {
    calls.add('delete:$id');
  }

  @override
  Future<void> toggleFavorite(String id) async {
    calls.add('favorite:$id');
  }
}
