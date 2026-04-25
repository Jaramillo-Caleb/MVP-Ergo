import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;
import 'dart:developer' as developer;

final class CalculationResult extends ffi.Struct {
  @ffi.Double()
  external double score;

  @ffi.Bool() // Corresponde al MarshalAs(UnmanagedType.U1) de C#
  external bool isAlert;

  external ffi.Pointer<Utf8> messagePtr; // Captura posibles mensajes de error
}

// 2. Firmas de funciones (Native = C#, Dart = Flutter)

// Firma para ProcessFrame
typedef ProcessFrameNative = CalculationResult Function(
  ffi.Pointer<ffi.Uint8> imagePtr,
  ffi.Int32 width,
  ffi.Int32 height,
  ffi.Pointer<ffi.Double> referencePtr,
);
typedef ProcessFrameDart = CalculationResult Function(
  ffi.Pointer<ffi.Uint8> imagePtr,
  int width,
  int height,
  ffi.Pointer<ffi.Double> referencePtr,
);

// Firma para InitEngine
typedef InitEngineNative = ffi.Void Function(ffi.Pointer<Utf8> modelPath);
typedef InitEngineDart = void Function(ffi.Pointer<Utf8> modelPath);

// Firma para el Logger
typedef NativeLogFn = ffi.Void Function(ffi.Pointer<Utf8> message);

class NativeBridge {
  late ffi.DynamicLibrary _lib;
  late ProcessFrameDart _processFrame;
  late InitEngineDart _initEngine;

  // Se guarda el callable para que el Garbage Collector no lo elimine
  late ffi.NativeCallable<NativeLogFn> _loggerExecutable;

  NativeBridge() {
    _loadLibrary();
    _setupBridge();
  }

  void _loadLibrary() {
    try {
      // En Windows, busca en la misma carpeta del .exe de Flutter
      _lib = ffi.DynamicLibrary.open('Ergo.Native.dll');
    } catch (e) {
      final String fullPath = p.join(Directory.current.path, 'Ergo.Native.dll');
      if (File(fullPath).existsSync()) {
        _lib = ffi.DynamicLibrary.open(fullPath);
      } else {
        throw Exception(
            "No se encontró Ergo.Native.dll. Revisa la carpeta de publicación.");
      }
    }
  }

  void _setupBridge() {
    // Vincular funciones
    _processFrame = _lib
        .lookupFunction<ProcessFrameNative, ProcessFrameDart>('process_frame');
    _initEngine = _lib
        .lookupFunction<InitEngineNative, InitEngineDart>('init_native_engine');

    // CONFIGURAR LOGGER: Conecta C# con la consola de Flutter
    final registerLogger = _lib.lookupFunction<
        ffi.Void Function(ffi.Pointer<ffi.NativeFunction<NativeLogFn>>),
        void Function(
            ffi.Pointer<ffi.NativeFunction<NativeLogFn>>)>('register_logger');

    _loggerExecutable =
        ffi.NativeCallable<NativeLogFn>.isolateLocal(_dartLogger);
    registerLogger(_loggerExecutable.nativeFunction);
  }

  // Esta función es la que imprime lo que viene de C#
  static void _dartLogger(ffi.Pointer<Utf8> message) {
    final msg = message.toDartString();
    developer.log(msg, name: 'C# NATIVE');
  }

  /// Inicializa el motor con la ruta del modelo ONNX
  void initialize(String modelPath) {
    final pathPtr = modelPath.toNativeUtf8();
    _initEngine(pathPtr);
    malloc.free(pathPtr);
  }

  /// Procesa un frame y devuelve (Score, IsAlert)
  (double, bool) processFrame(
      List<double> referenceVector, List<int> imageBytes) {
    // 1. Alocar memoria para el vector de referencia (15 doubles)
    final refPtr = malloc<ffi.Double>(referenceVector.length);
    for (var i = 0; i < referenceVector.length; i++) {
      refPtr[i] = referenceVector[i];
    }

    // 2. Alocar memoria para la imagen (RGBA = width * height * 4)
    final imgPtr = malloc<ffi.Uint8>(imageBytes.length);
    final typedList = imgPtr.asTypedList(imageBytes.length);
    typedList.setAll(0, imageBytes);

    // 3. LLAMADA NATIVA (Aquí ocurre lo de C# + ONNX)
    // Asumimos que la imagen ya viene de la cámara como 256x256
    final result = _processFrame(imgPtr, 256, 256, refPtr);

    final score = result.score;
    final alert = result.isAlert;

    // 4. LIBERAR MEMORIA
    malloc.free(refPtr);
    malloc.free(imgPtr);

    return (score, alert);
  }
}
