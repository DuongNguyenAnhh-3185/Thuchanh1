import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  AppDatabase._();

  static Future<Database> open({String? databasePath}) async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final directory = databasePath ?? await getDatabasesPath();
    return openDatabase(
      databasePath ?? '$directory/cashew_study_hub.db',
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE study_documents (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            subject TEXT NOT NULL,
            category TEXT NOT NULL,
            description TEXT NOT NULL,
            file_type TEXT NOT NULL,
            resource_location TEXT NOT NULL,
            created_at TEXT NOT NULL,
            is_favorite INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await _insertSampleDocuments(database);
      },
    );
  }

  static Future<void> _insertSampleDocuments(Database database) async {
    final sampleDocuments = [
      {
        'id': 'doc-1',
        'title': 'Giới thiệu về Cấu trúc dữ liệu',
        'subject': 'Kỹ thuật phần mềm',
        'category': 'lecture',
        'description':
            'Bài giảng tổng quan về cấu trúc dữ liệu và ứng dụng trong lập trình.',
        'file_type': 'PDF',
        'resource_location': '',
        'created_at': '2024-09-05T00:00:00.000',
        'is_favorite': 1,
      },
      {
        'id': 'doc-2',
        'title': 'Bài tập tuần 3: Cây nhị phân',
        'subject': 'Cấu trúc dữ liệu',
        'category': 'assignment',
        'description':
            'Tập hợp các bài tập thực hành về cây nhị phân, đệ quy và duyệt cây.',
        'file_type': 'DOCX',
        'resource_location': '',
        'created_at': '2024-09-08T00:00:00.000',
        'is_favorite': 0,
      },
      {
        'id': 'doc-3',
        'title': 'Tài liệu chuẩn OOP trong Java',
        'subject': 'Lập trình hướng đối tượng',
        'category': 'reference',
        'description':
            'Tài liệu tham khảo chính thức về nguyên lý OOP và cách xây dựng mô hình lớp.',
        'file_type': 'PDF',
        'resource_location': '',
        'created_at': '2024-09-12T00:00:00.000',
        'is_favorite': 0,
      },
      {
        'id': 'doc-4',
        'title': 'Slide hệ điều hành',
        'subject': 'Hệ điều hành',
        'category': 'lecture',
        'description': 'Tổng hợp slide về tiến trình, bộ nhớ và lập lịch.',
        'file_type': 'PPTX',
        'resource_location': '',
        'created_at': '2024-09-15T00:00:00.000',
        'is_favorite': 0,
      },
    ];

    final batch = database.batch();
    for (final document in sampleDocuments) {
      batch.insert('study_documents', document);
    }
    await batch.commit(noResult: true);
  }
}
