import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/app_database.dart';
import 'data/repositories/preferences_document_repository.dart';
import 'data/repositories/sqlite_document_repository.dart';
import 'domain/repositories/document_repository.dart';
import 'domain/usecases/document_use_cases.dart';
import 'presentation/controllers/document_list_controller.dart';
import 'presentation/pages/study_home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final DocumentRepository repository;
  if (kIsWeb) {
    repository = PreferencesDocumentRepository(
      await SharedPreferences.getInstance(),
    );
  } else {
    final database = await AppDatabase.open();
    repository = SqliteDocumentRepository(database);
  }
  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  MyApp({required DocumentRepository repository, super.key})
    : controller = DocumentListController(
        GetDocuments(repository),
        const SearchDocuments(),
        CreateDocument(repository),
        UpdateDocument(repository),
        DeleteDocument(repository),
        ToggleDocumentFavorite(repository),
      );

  final DocumentListController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cashew Study Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: StudyHomePage(controller: controller),
    );
  }
}
