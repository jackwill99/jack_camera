// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:encrypt/encrypt.dart';

class JackFernetModel {
  final Encrypted encrypted;
  final Fernet fernet;

  /// ```dart
  ///
  /// print(encrypted.base64); // random cipher text
  /// print(fernet.extractTimestamp(encrypted.bytes)); // unix timestamp
  /// ```
  JackFernetModel({
    required this.encrypted,
    required this.fernet,
  });
}

class JackEncryptData {
  final String securekey;

  /// # README.md (read this bro)
  /// ### AES Algorithm
  ///(Advanced Encryption Standard) has become the encryption algorithm of choice for governments, financial institutions, and security-conscious enterprises around the world. The U.S. National Security Agency (NSC) uses it to protect the country’s “top secret” information.
  ///
  ///### Fernet Algorithm
  ///Fernet is an asymmetric encryption method that makes sure that the message encrypted cannot be manipulated/read without the key. It uses URL-safe encoding for the keys. Fernet also uses 128-bit AES in CBC mode and PKCS7 padding, with HMAC using SHA256 for authentication. The IV is created from os. random(). All of this is the kind of thing that good software needs.
  ///
  /// ```dart
  /// final encrypt = encryptData.encryptFernet("This is Fernet");
  /// final decrypt = encryptData.decryptFernet(
  ///                   Encrypted(
  ///                     base64.decode(encrypt.encrypted.base64)
  ///                   )
  ///                 );
  ///  print(encrypt.encrypted.base64); // This can be use as a standard , this can be decrypted by this way
  ///  print(decrypt);   // this is decrypted value
  ///
  /// ```
  JackEncryptData({required this.securekey});

  /// for AES Encrypt Algorithms
  Encrypted encryptAES(String plainText) {
    final key = Key.fromUtf8(securekey);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted;
  }

  /// for AES Decrypt Algorithms
  String decryptAES(Encrypted encrypted) {
    final key = Key.fromUtf8(securekey);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }


  /// for Fernet Encrypt Algorithms
  ///
  /// ```dart
  /// final encrypt = encryptData.encryptFernet("This is Fernet");
  /// final decrypt = encryptData.decryptFernet(
  ///                   Encrypted(
  ///                     base64.decode(encrypt.encrypted.base64)
  ///                   )
  ///                 );
  ///  print(encrypt.encrypted.base64); // This can be use as a standard , this can be decrypted by this way
  ///  print(decrypt);   // this is decrypted value
  ///
  /// ```
  JackFernetModel encryptFernet(String plainText) {
    final key = Key.fromUtf8(securekey);
    // final iv = IV.fromLength(16);

    ///* if u want to use b64 use it.
    ///* but in this case, Fernet request only 32 url-safe base64-encoded bytes
    final b64key = Key.fromUtf8(base64Url.encode(key.bytes));
    // if you need to use the ttl feature, you'll need to use APIs in the algorithm itself
    final fernet = Fernet(key);
    final encrypter = Encrypter(fernet);
    final fernetEncrypted = encrypter.encrypt(plainText);
    return JackFernetModel(encrypted: fernetEncrypted, fernet: fernet);
  }

  /// for Fernet Decrypt Algorithms
  /// ```dart
  /// final encrypt = encryptData.encryptFernet("This is Fernet");
  /// final decrypt = encryptData.decryptFernet(
  ///                   Encrypted(
  ///                     base64.decode(encrypt.encrypted.base64)
  ///                   )
  ///                 );
  ///  print(encrypt.encrypted.base64); // This can be use as a standard , this can be decrypted by this way
  ///  print(decrypt);   // this is decrypted value
  ///
  /// ```
  String decryptFernet(Encrypted encrypted) {
    final key = Key.fromUtf8(securekey);
    // final iv = IV.fromLength(16);

    ///* if u want to use b64 use it.
    ///* but in this case, Fernet request only 32 url-safe base64-encoded bytes
    final b64key = Key.fromUtf8(base64Url.encode(key.bytes));
    final fernet = Fernet(key);
    final encrypter = Encrypter(fernet);
    final fernetDecrypted = encrypter.decrypt(encrypted);
    return fernetDecrypted;
  }
}
