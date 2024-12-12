import 'dart:convert';
import 'package:encrypt/encrypt.dart' as enc;

class EncryptionService {
  final enc.Key key;
  final enc.IV iv;
  //final enc.Encrypter encrypter;

  EncryptionService(this.key, this.iv);// : encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));


  String encrypt(String plainText) {
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    print(encrypted.base64);
    return encrypted.base64;
  }

  

  String decrypt(String encryptedText) {
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    print(decrypted);
    return decrypted;
  }
}
