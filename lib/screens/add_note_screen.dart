import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../services/encryption_service.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _notesBox = Hive.box('notes');

  late EncryptionService _encryptionService;
  bool _isKeysLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeEncryptionService();
  }

  Future<void> _initializeEncryptionService() async {
    try {
      // Генерация ключа и IV для AES
      final key = encrypt.Key.fromUtf8("my32lengthsupersecretnooneknows1"); // 32 байта для AES-256
      final iv = encrypt.IV.fromLength(16);//fromLength(16); // 16 байт для AES

      // Инициализация сервиса шифрования
      setState(() {
        _encryptionService = EncryptionService(key, iv);
        _isKeysLoaded = true; // Указывает, что ключи загружены
      });
    } catch (e) {
      print('Ошибка при инициализации сервиса шифрования: $e');
    }
  }

  void _saveNote() {
    if (!_isKeysLoaded) return; // Не сохранять, если ключи не загружены

    final title = _titleController.text;
    final content = _contentController.text;

    // Шифруем контент
    final encryptedContent = _encryptionService.encrypt(content);

    // Сохраняем заметку в Hive
    _notesBox.add({'title': title, 'content': encryptedContent});
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Note')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isKeysLoaded ? _saveNote : null,
              child: Text(_isKeysLoaded ? 'Save' : 'Loading keys...'),
            ),
          ],
        ),
      ),
    );
  }
}
