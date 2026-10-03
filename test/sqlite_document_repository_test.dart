import 'package:flutter_test/flutter_test.dart';
import 'package:lab_01/data/datasources/app_database.dart';
import 'package:lab_01/data/repositories/sqlite_document_repository.dart';
import 'package:lab_01/domain/entities/study_document.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'persists document create, read, update, favorite, and delete',
    () async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final database = await AppDatabase.open(
        databasePath: inMemoryDatabasePath,
      );
      addTearDown(database.close);
      final repository = SqliteDocumentRepository(database);

      final initialDocuments = await repository.getAll();
      expect(initialDocuments, hasLength(4));

      final created = await repository.create(
        StudyDocument(
          id: '',
          title: 'Tài liệu SQLite',
          subject: 'Cơ sở dữ liệu',
          category: StudyDocumentCategory.reference,
          description: 'Tài liệu lưu ở SQLite',
          fileType: 'PDF',
          resourceLocation: 'https://example.com/sqlite.pdf',
          createdAt: DateTime(2026),
        ),
      );
      expect(created.id, isNotEmpty);
      expect((await repository.getAll()).first.title, 'Tài liệu SQLite');

      final updated = created.copyWith(title: 'Tài liệu SQLite đã sửa');
      await repository.update(updated);
      await repository.toggleFavorite(created.id);
      final saved = (await repository.getAll()).first;
      expect(saved.title, 'Tài liệu SQLite đã sửa');
      expect(saved.isFavorite, isTrue);
      expect(saved.resourceLocation, 'https://example.com/sqlite.pdf');

      await repository.delete(created.id);
      expect(
        (await repository.getAll()).any(
          (document) => document.id == created.id,
        ),
        isFalse,
      );
    },
  );
}
