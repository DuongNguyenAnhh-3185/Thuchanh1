import 'package:flutter/material.dart';

import '../../domain/entities/study_document.dart';

class DocumentFormPage extends StatefulWidget {
  const DocumentFormPage({required this.document, super.key});

  final StudyDocument? document;

  @override
  State<DocumentFormPage> createState() => _DocumentFormPageState();
}

class _DocumentFormPageState extends State<DocumentFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _subjectController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _fileTypeController;
  late final TextEditingController _resourceController;
  late StudyDocumentCategory _category;

  bool get _isEditing => widget.document != null;

  @override
  void initState() {
    super.initState();
    final document = widget.document;
    _titleController = TextEditingController(text: document?.title ?? '');
    _subjectController = TextEditingController(text: document?.subject ?? '');
    _descriptionController = TextEditingController(
      text: document?.description ?? '',
    );
    _fileTypeController = TextEditingController(
      text: document?.fileType ?? '',
    );
    _resourceController = TextEditingController(
      text: document?.resourceLocation ?? '',
    );
    _category = document?.category ?? StudyDocumentCategory.lecture;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _fileTypeController.dispose();
    _resourceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final existing = widget.document;
    Navigator.of(context).pop(
      StudyDocument(
        id: existing?.id ?? '',
        title: _titleController.text.trim(),
        subject: _subjectController.text.trim(),
        category: _category,
        description: _descriptionController.text.trim(),
        fileType: _fileTypeController.text.trim().toUpperCase(),
        resourceLocation: _resourceController.text.trim(),
        createdAt: existing?.createdAt ?? DateTime.now(),
        isFavorite: existing?.isFavorite ?? false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa tài liệu' : 'Thêm tài liệu'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tên tài liệu',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Vui lòng nhập tên tài liệu.'
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<StudyDocumentCategory>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Loại tài liệu',
                border: OutlineInputBorder(),
              ),
              items: StudyDocumentCategory.values
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    ),
                  )
                  .toList(),
              onChanged: (category) {
                if (category != null) {
                  setState(() => _category = category);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fileTypeController,
              decoration: const InputDecoration(
                labelText: 'Định dạng (PDF, DOCX...)',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Vui lòng nhập định dạng tài liệu.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _resourceController,
              decoration: const InputDecoration(
                labelText: 'Link hoặc đường dẫn file',
                hintText: 'https://... hoặc đường dẫn file',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Môn học',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save),
              label: Text(_isEditing ? 'Lưu thay đổi' : 'Lưu tài liệu'),
            ),
          ],
        ),
      ),
    );
  }
}
