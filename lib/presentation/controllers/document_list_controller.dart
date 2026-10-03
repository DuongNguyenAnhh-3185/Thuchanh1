import 'package:flutter/foundation.dart';

import '../../domain/entities/study_document.dart';
import '../../domain/usecases/document_use_cases.dart';

class DocumentListController extends ChangeNotifier {
  DocumentListController(
    this._getDocuments,
    this._searchDocuments,
    this._createDocument,
    this._updateDocument,
    this._deleteDocument,
    this._toggleFavorite,
  );

  final GetDocuments _getDocuments;
  final SearchDocuments _searchDocuments;
  final CreateDocument _createDocument;
  final UpdateDocument _updateDocument;
  final DeleteDocument _deleteDocument;
  final ToggleDocumentFavorite _toggleFavorite;

  List<StudyDocument> _documents = const [];
  List<StudyDocument> _visibleDocuments = const [];
  String _query = '';
  bool _isLoading = false;
  String? _error;

  List<StudyDocument> get documents => _visibleDocuments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;

  List<StudyDocument> documentsForCategory(StudyDocumentCategory category) {
    return _visibleDocuments
        .where((document) => document.category == category)
        .toList(growable: false);
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _documents = await _getDocuments();
      _applySearch();
    } catch (error) {
      _error = 'Không thể tải tài liệu: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _query = query;
    _applySearch();
    notifyListeners();
  }

  Future<void> create(StudyDocument document) async {
    await _performMutation(() async {
      await _createDocument(document);
    });
  }

  Future<void> update(StudyDocument document) async {
    await _performMutation(() => _updateDocument(document));
  }

  Future<void> delete(String id) async {
    await _performMutation(() => _deleteDocument(id));
  }

  Future<void> toggleFavorite(String id) async {
    await _performMutation(() => _toggleFavorite(id));
  }

  Future<void> _performMutation(Future<void> Function() mutation) async {
    _error = null;
    try {
      await mutation();
      _documents = await _getDocuments();
      _applySearch();
      notifyListeners();
    } catch (error) {
      _error = 'Thao tác không thành công: $error';
      notifyListeners();
      rethrow;
    }
  }

  void _applySearch() {
    _visibleDocuments = _searchDocuments(_documents, _query);
  }
}
