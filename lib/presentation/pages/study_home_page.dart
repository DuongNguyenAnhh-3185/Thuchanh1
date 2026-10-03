import 'package:flutter/material.dart';

import '../../domain/entities/study_document.dart';
import '../controllers/document_list_controller.dart';
import 'document_form_page.dart';

class StudyHomePage extends StatefulWidget {
  const StudyHomePage({required this.controller, super.key});

  final DocumentListController controller;

  @override
  State<StudyHomePage> createState() => _StudyHomePageState();
}

class _StudyHomePageState extends State<StudyHomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const List<StudyDocumentCategory> _categories = [
    StudyDocumentCategory.lecture,
    StudyDocumentCategory.assignment,
    StudyDocumentCategory.reference,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    widget.controller.addListener(_onControllerChanged);
    widget.controller.load();
  }

  @override
  void didUpdateWidget(covariant StudyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      widget.controller.load();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openForm([StudyDocument? document]) async {
    final result = await Navigator.of(context).push<StudyDocument>(
      MaterialPageRoute(
        builder: (_) => DocumentFormPage(document: document),
      ),
    );
    if (result == null) {
      return;
    }
    try {
      if (document == null) {
        await widget.controller.create(result);
      } else {
        await widget.controller.update(result);
      }
    } catch (error) {
      if (mounted) {
        _showError(error);
      }
    }
  }

  Future<void> _confirmDelete(StudyDocument document) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tài liệu?'),
        content: Text('Bạn có chắc muốn xóa "${document.title}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) {
      return;
    }
    try {
      await widget.controller.delete(document.id);
    } catch (error) {
      if (mounted) {
        _showError(error);
      }
    }
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Không thể thực hiện thao tác: $error')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cashew Study Hub'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: _categories.map((category) => Tab(text: category.label)).toList(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên hoặc loại tài liệu...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: widget.controller.search,
            ),
          ),
          if (widget.controller.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MaterialBanner(
                content: Text(widget.controller.error!),
                actions: [
                  TextButton(
                    onPressed: widget.controller.load,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: widget.controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: _categories
                        .map((category) => _buildCategoryList(category, theme))
                        .toList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Thêm tài liệu'),
      ),
    );
  }

  Widget _buildCategoryList(
    StudyDocumentCategory category,
    ThemeData theme,
  ) {
    final documents = widget.controller.documentsForCategory(category);
    if (documents.isEmpty) {
      return Center(
        child: Text(
          'Không có tài liệu nào trong ${category.label.toLowerCase()}.',
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: documents.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final document = documents[index];
        return Card(
          elevation: 1,
          child: ListTile(
            onTap: () => _openForm(document),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(document.fileType.substring(0, 1)),
            ),
            title: Text(document.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(document.subject),
                const SizedBox(height: 6),
                Text(
                  document.description.isEmpty
                      ? document.fileType
                      : document.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (document.resourceLocation.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    document.resourceLocation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            trailing: PopupMenuButton<String>(
              tooltip: 'Thao tác tài liệu',
              onSelected: (action) {
                if (action == 'favorite') {
                  _runControllerAction(
                    () => widget.controller.toggleFavorite(document.id),
                  );
                } else if (action == 'edit') {
                  _openForm(document);
                } else if (action == 'delete') {
                  _confirmDelete(document);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'favorite',
                  child: Text(
                    document.isFavorite ? 'Bỏ yêu thích' : 'Đánh dấu yêu thích',
                  ),
                ),
                const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                const PopupMenuItem(value: 'delete', child: Text('Xóa')),
              ],
              icon: Icon(
                document.isFavorite ? Icons.star : Icons.more_vert,
                color: document.isFavorite ? Colors.amber : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _runControllerAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (mounted) {
        _showError(error);
      }
    }
  }
}
