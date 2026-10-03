import 'package:flutter_test/flutter_test.dart';
import 'package:lab_01/data/repositories/preferences_document_repository.dart';
import 'package:lab_01/domain/entities/study_document.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'persists web documents and initializes sample documents once',
    () async {
      SharedPreferences.setMockInitialValues({});
      final repository = PreferencesDocumentRepository(
        await SharedPreferences.getInstance(),
      );

      expect(await repository.getAll(), hasLength(4));
      final created = await repository.create(
        StudyDocument(
          id: '',
          title: 'Tài liệu Web',
          subject: 'Flutter',
          category: StudyDocumentCategory.lecture,
          description: 'Lưu trữ trên trình duyệt',
          fileType: 'PDF',
          resourceLocation: 'https://example.com/flutter.pdf',
          createdAt: DateTime(2026),
        ),
      );

      final reloadedRepository = PreferencesDocumentRepository(
        await SharedPreferences.getInstance(),
      );
      final stored = await reloadedRepository.getAll();
      expect(stored, hasLength(5));
      expect(stored.first.id, created.id);
      expect(stored.first.resourceLocation, 'https://example.com/flutter.pdf');

      await reloadedRepository.toggleFavorite(created.id);
      expect((await repository.getAll()).first.isFavorite, isTrue);

      await reloadedRepository.delete(created.id);
      expect(await repository.getAll(), hasLength(4));
    },
  );
}
