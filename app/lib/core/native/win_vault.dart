import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:cryptography/cryptography.dart';
import 'package:convert/convert.dart';

class WinVault {
  static const String _targetName = 'ErgoDesktop/DatabaseKey/v1';

  /// Obtiene la clave de 256 bits (CSPRNG) o la genera si no existe.
  static Future<String> getOrCreateDatabaseKey() async {
    final existing = _readCredential();
    if (existing != null) return existing;

    // Alta entropía para la auditoría de seguridad
    final algorithm = AesGcm.with256bits();
    final secretKey = await algorithm.newSecretKey();
    final keyBytes = await secretKey.extractBytes();

    final newKeyHex = hex.encode(keyBytes);
    _writeCredential(newKeyHex);
    return newKeyHex;
  }

  static void _writeCredential(String password) {
    using((arena) {
      // Usamos el operador de llamada de arena para alocar la estructura
      final pCredential = arena<CREDENTIAL>();

      pCredential.ref.Type = CRED_TYPE_GENERIC;

      // NOTA: Usamos arena.pwstr() directamente del paquete win32 6.1.0
      pCredential.ref.TargetName = arena.pwstr(_targetName);
      pCredential.ref.Persist = CRED_PERSIST_LOCAL_MACHINE;

      final blob = password.toNativeUtf8(allocator: arena);
      // El tamaño en bytes del string hexadecimal
      pCredential.ref.CredentialBlobSize = password.length;
      pCredential.ref.CredentialBlob = blob.cast<Uint8>();

      // Win32Result<bool> en win32 6.x
      final result = CredWrite(pCredential, 0);

      if (result.value == false) {
        // HRESULT_FROM_WIN32 convierte el código de error para WindowsException
        throw WindowsException(HRESULT_FROM_WIN32(result.error));
      }
    });
  }

  static String? _readCredential() {
    return using((arena) {
      // Necesitamos un puntero a un puntero para recibir la dirección de la estructura
      final ppCredential = arena<Pointer<CREDENTIAL>>();

      // CredRead en 6.1.0 simplificó la firma a 3 parámetros (PCWSTR, int, PtrPtr)
      final result = CredRead(
        arena.pcwstr(_targetName),
        CRED_TYPE_GENERIC,
        ppCredential,
      );

      if (result.value == false) return null;

      final pCredential = ppCredential.value;
      try {
        final credential = pCredential.ref;
        final blob = credential.CredentialBlob.cast<Utf8>().toDartString(
          length: credential.CredentialBlobSize,
        );
        return blob;
      } finally {
        // Liberar la memoria alocada por el sistema operativo
        CredFree(pCredential);
      }
    });
  }
}
