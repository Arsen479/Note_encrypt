import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../services/encryption_service.dart';
import 'add_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encrypted Notes')),
      body: _isKeysLoaded
          ? ValueListenableBuilder(
              valueListenable: _notesBox.listenable(),
              builder: (context, Box box, _) {
                if (box.isEmpty) {
                  return const Center(child: Text('No notes yet'));
                }

                return ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final note = box.getAt(index);
                    final decryptedContent =
                        _encryptionService.decrypt(note['content']);
                    return ListTile(
                      title: Text(note['title']),
                      subtitle: Text(decryptedContent),
                    );
                  },
                );
              },
            )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNoteScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
