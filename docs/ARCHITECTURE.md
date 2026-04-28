# ERGO Architecture

## High-Level Overview

ERGO follows a layered architecture with a clear separation between the UI/Business logic (Flutter) and high-performance processing (C# Native).

### 1. Flutter Layer (`/app`)

- **Presentation**: BLoC/Provider pattern (standardized widgets in `core/widgets`).
- **Domain**: Entities and abstract service definitions.
- **Data**: 
  - **Repositories/Services**: Implement local data fetching and coordinate with the native layer.
  - **Persistence**: `drift` for SQLite management.
  - **FFI Bridge**: `NativeBridge` class handles communication with the DLL.

### 2. Native Layer (`/native/Ergo.Native`)

Written in C# and compiled to a native library using .NET 9 Native AOT.

- **Bridge.cs**: Entry point for FFI calls. Exports methods like `init_native_engine`, `process_frame`, and `extract_vectors`.
- **VisionService**: Handles ONNX Runtime inference using MediaPipe Pose models. Performs image preprocessing (OpenCV) and landmark filtering.
- **MathEngine**: Pure mathematical logic for posture comparison. Uses geometric ratios to detect deviations independently of the user's distance from the camera.

## Data Flow: Posture Monitoring

1.  **Capture**: Flutter captures a camera frame.
2.  **Transfer**: Bytes are passed to the `process_frame` exported function via FFI.
3.  **Inference**: `VisionService` runs the ONNX model to get 3D landmarks.
4.  **Geometry**: `MathEngine` calculates ratios (Height/ShoulderWidth, Eye Angle).
5.  **Comparison**: The current frame ratios are compared against the calibrated reference.
6.  **Result**: An `IsAlert` boolean and a `Score` are returned to Flutter.
7.  **UX**: If alerts are consistent, Flutter triggers a local system notification.

## FFI Integration

The communication uses `dart:ffi`. Structs are mirrored between C# and Dart to ensure memory alignment:

| C# Struct | Dart Struct | Purpose |
| :--- | :--- | :--- |
| `CalculationResult` | `CalculationResult` | Returns monitoring score and alert status. |
| `double[]` | `Pointer<Double>` | Transfers landmark vectors. |
