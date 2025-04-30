// ignore_for_file: avoid_print, duplicate_ignore

import 'package:encrypt/encrypt.dart';

class MyEncriptionDecription {
  //For AES Encryption/Decryption

  // static encryptWithAESKey(String data) {
  //   try {
  //     encrypt.Key aesKey = encrypt.Key.fromUtf8("e16ce888a20dadb8");
  //     final encrypter = encrypt.Encrypter(encrypt.AES(aesKey));
  //     if (data.isNotEmpty) {
  //       encrypt.Encrypted encryptedData =
  //           encrypter.encrypt(data, iv: encrypt.IV.fromLength(16));
  //       return encryptedData.base64;
  //     } else if (data.isEmpty) {
  //       // ignore: avoid_print
  //       print('Data is empty');
  //     }
  //   } catch (e) {
  //     print("Have Error: $e");
  //   }
  // }
  static encryptWithAESKey(String value) {
    final key = Key.fromUtf8("1245714587458888"); //hardcode
    final iv = IV.fromUtf8("e16ce888a20dadb8"); //hardcode

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(value, iv: iv);

    return encrypted.base64;
  }

  static String decryptWithAESKey(String encrypted) {
    try {
      final key = Key.fromUtf8(
          "1245714587458888"); //hardcode combination of 16 character
      final iv = IV
          .fromUtf8("e16ce888a20dadb8"); //hardcode combination of 16 character

      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      Encrypted enBase64 = Encrypted.from64(encrypted);
      final decrypted = encrypter.decrypt(enBase64, iv: iv);
      return decrypted;
    } catch (e) {
      if (e == "") {
        print("the ERROR: $e");
      }
    }
    return encrypted;
  }

  // static decryptWithAESKey(String data) {
  //   try {
  //     encrypt.Key aesKey = encrypt.Key.fromLength(16);
  //     final encrypter = encrypt.Encrypter(encrypt.AES(aesKey));
  //     encrypt.Encrypted encrypted = encrypt.Encrypted.fromBase64(data);
  //     if (data.isNotEmpty) {
  //       String decryptedData =
  //           encrypter.decrypt(encrypted, iv: encrypt.IV.fromLength(16));
  //       return decryptedData;
  //     } else if (data.isEmpty) {
  //       print('Data is empty');
  //     }
  //   } catch (e) {
  //     // If we get an ArgumentError, it means that the data is corrupted.
  //     // We can try to ignore the error and return an empty string, or we
  //     // can throw the error to the caller.
  //     if (e is ArgumentError) {
  //       print("The data is corrupted: $e");
  //       return '';
  //     } else {
  //       rethrow;
  //     }
  //   }
  // }
}
