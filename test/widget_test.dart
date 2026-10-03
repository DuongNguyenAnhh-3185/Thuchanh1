import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_01/domain/entities/study_document.dart';
import 'package:lab_01/domain/repositories/document_repository.dart';
import 'package:lab_01/main.dart';

void main() {
  testWidgets('shows the study workspace and saved documents', (tester) async {
    await tester.pumpWidget(MyApp(repository: _MemoryDocumentRepository.seeded()));
    await tester.pumpAndSettle();

    expect(find.text('Cashew Study Hub'), findsOneWidget);
    expect(find.text('Bài giảng'), findsWidgets);
    expect(find.text('Tài liệu tham khảo'), findsWidgets);
    expect(find.text('Giới thiệu về Cấu trúc dữ liệu'), findsOneWidget);
  });

  testWidgets('creates, edits, searches, and deletes a document', (
    tester,
  ) async {
    await tester.pumpWidget(MyApp(repository: _MemoryDocumentRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Thêm tài liệu'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Flutter SOLID');
    await tester.enterText(find.byType(TextFormField).at(1), 'PDF');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'https://example.com/solid.pdf',
    );
    await tester.tap(find.text('Lưu tài liệu'));
    await tester.pumpAndSettle();

    expect(find.text('Flutter SOLID'), findsOneWidget);
    expect(find.text('https://example.com/solid.pdf'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'flutter');
    await tester.pumpAndSettle();
    expect(find.text('Flutter SOLID'), findsOneWidget);

    await tester.tap(find.text('Flutter SOLID'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Flutter Clean');
    await tester.tap(find.text('Lưu thay đổi'));
    await tester.pumpAndSettle();
    expect(find.text('Flutter Clean'), findsOneWidget);

    await tester.tap(find.byTooltip('Thao tác tài liệu').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa').last);
    await tester.pumpAndSettle();
    expect(find.text('Flutter Clean'), findsNothing);
  });
}

class _MemoryDocumentRepository implements DocumentRepository {
  _MemoryDocumentRepository([List<StudyDocument>? initialDocuments])
    : _documents = initialDocuments ?? [];

  final List<StudyDocument> _documents;
  var _nextId = 0;

  factory _MemoryDocumentRepository.seeded() {
    return _MemoryDocumentRepository([
      StudyDocument(
        id: 'sample-1',
        title: 'Giới thiệu về Cấu trúc dữ liệu',
        subject: 'Kỹ thuật phần mềm',
        category: StudyDocumentCategory.lecture,
        description: 'Bài giảng mẫu',
        fileType: 'PDF',
        resourceLocation: '',
        createdAt: DateTime(2024),
      ),
    ]);
  }

  @override
  Future<List<StudyDocument>> getAll() async => List.unmodifiable(_documents);

  @override
  Future<StudyDocument> create(StudyDocument document) async {
    final savedDocument = document.copyWith(id: 'created-${_nextId++}');
    _documents.insert(0, savedDocument);
    return savedDocument;
  }

  @override
  Future<void> update(StudyDocument document) async {
    final index = _documents.indexWhere((item) => item.id == document.id);
    if (index == -1) {
      throw StateError('Document not found');
    }
    _documents[index] = document;
  }

  @override
  Future<void> delete(String id) async {
    final index = _documents.indexWhere((item) => item.id == id);
    if (index == -1) {
      throw StateError('Document not found');
    }
    _documents.removeAt(index);
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final index = _documents.indexWhere((item) => item.id == id);
    if (index == -1) {
      throw StateError('Document not found');
    }
    _documents[index] = _documents[index].copyWith(
      isFavorite: !_documents[index].isFavorite,
    );
  }
}
