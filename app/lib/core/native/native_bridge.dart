import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;
import 'dart:typed_data';

final class CalculationResult extends ffi.Struct {
  @ffi.Double()
  external double score;

  @ffi.Int32()
  external int isAlert;

  external ffi.Pointer<Utf8> messagePtr;
}

typedef ProcessFrameNative = CalculationResult Function(
  ffi.Pointer<ffi.Uint8> imagePtr,
  ffi.Int32 size,
  ffi.Pointer<ffi.Double> referencePtr,
  ffi.Double threshold,
);
typedef ProcessFrameDart = CalculationResult Function(
  ffi.Pointer<ffi.Uint8> imagePtr,
  int size,
  ffi.Pointer<ffi.Double> referencePtr,
  double threshold,
);

typedef ExtractVectorsNative = ffi.Int32 Function(
  ffi.Pointer<ffi.Pointer<ffi.Uint8>> imagesPtr,
  ffi.Pointer<ffi.Int32> sizesPtr,
  ffi.Int32 count,
  ffi.Pointer<ffi.Double> outputVectorsPtr,
);
typedef ExtractVectorsDart = int Function(
  ffi.Pointer<ffi.Pointer<ffi.Uint8>> imagesPtr,
  ffi.Pointer<ffi.Int32> sizesPtr,
  int count,
  ffi.Pointer<ffi.Double> outputVectorsPtr,
);

typedef InitEngineNative = ffi.Void Function(ffi.Pointer<Utf8> modelPath);
typedef InitEngineDart = void Function(ffi.Pointer<Utf8> modelPath);

class NativeBridge {
  late ffi.DynamicLibrary _lib;
  late ProcessFrameDart _processFrame;
  late ExtractVectorsDart _extractVectors;
  late InitEngineDart _initEngine;

  NativeBridge() {
    _loadLibrary();
    _setupBridge();
  }

  void _loadLibrary() {
    try {
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
    _processFrame = _lib
        .lookupFunction<ProcessFrameNative, ProcessFrameDart>('process_frame');
    _extractVectors =
        _lib.lookupFunction<ExtractVectorsNative, ExtractVectorsDart>(
            'extract_vectors');
    _initEngine = _lib
        .lookupFunction<InitEngineNative, InitEngineDart>('init_native_engine');
  }

  void initialize(String modelPath) {
    final pathPtr = modelPath.toNativeUtf8();
    _initEngine(pathPtr);
    malloc.free(pathPtr);
  }

  (double, bool) processFrame(
      List<double> referenceVector, List<int> imageBytes, double threshold) {
    final refPtr = malloc<ffi.Double>(referenceVector.length);
    for (var i = 0; i < referenceVector.length; i++) {
      refPtr[i] = referenceVector[i];
    }

    final imgPtr = malloc<ffi.Uint8>(imageBytes.length);
    final typedList = imgPtr.asTypedList(imageBytes.length);
    typedList.setAll(0, imageBytes);

    final result = _processFrame(imgPtr, imageBytes.length, refPtr, threshold);

    final score = result.score;
    final bool alert = result.isAlert != 0;

    malloc.free(refPtr);
    malloc.free(imgPtr);

    return (score, alert);
  }

  List<List<double>> extractMultipleVectors(List<Uint8List> images) {
    if (images.isEmpty) return [];

    final int count = images.length;
    final imagesPtr = malloc<ffi.Pointer<ffi.Uint8>>(count);
    final sizesPtr = malloc<ffi.Int32>(count);
    final outPtr = malloc<ffi.Double>(count * 15);

    final List<ffi.Pointer<ffi.Uint8>> allocatedImages = [];

    for (int i = 0; i < count; i++) {
      final img = images[i];
      final p = malloc<ffi.Uint8>(img.length);
      p.asTypedList(img.length).setAll(0, img);
      imagesPtr[i] = p;
      sizesPtr[i] = img.length;
      allocatedImages.add(p);
    }

    final int successful = _extractVectors(imagesPtr, sizesPtr, count, outPtr);

    List<List<double>> results = [];
    for (int i = 0; i < successful; i++) {
      results.add(List<double>.generate(15, (j) => outPtr[i * 15 + j]));
    }

    for (var p in allocatedImages) {
      malloc.free(p);
    }
    malloc.free(imagesPtr);
    malloc.free(sizesPtr);
    malloc.free(outPtr);

    return results;
  }
}
