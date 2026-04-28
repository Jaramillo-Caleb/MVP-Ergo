# ERGO: Desktop Ergonomics & Productivity

ERGO is a cross-platform desktop application (Flutter + .NET Native) designed to improve workspace posture and boost productivity through the Pomodoro technique and task management.

## Key Features

- **Posture Monitoring**: Real-time AI-powered posture analysis using MediaPipe.
- **Geometric Calibration**: Calibrate your ideal posture and get alerted when slouching or tilting your head.
- **Pomodoro Timer**: Integrated work/break sessions with customizable intervals.
- **Task Management**: Simple and effective task tracking with priority-based sorting.
- **Native Performance**: Vision and Math engines written in C# and compiled to Native AOT for maximum efficiency.

## Technology Stack

- **Frontend**: Flutter (Dart)
- **AI/Vision Engine**: C# .NET 9 (Native AOT)
- **Models**: MediaPipe Pose Landmark (Lite) via ONNX Runtime.
- **Computer Vision**: OpenCVSharp.
- **Storage**: SQLite (Drift) with SQLCipher encryption.

## Architecture

The project is divided into two main components:

1.  **/app**: The Flutter application handling UI, local state, and database persistence.
2.  **/native/Ergo.Native**: C# project that exports a high-performance DLL via FFI. It handles ONNX model inference and complex geometric calculations.

## Setup & Installation

### Prerequisites

- Flutter SDK (latest stable)
- .NET 9 SDK
- C++ Build Tools (for Native AOT compilation)

### Building the Native Component

```powershell
cd native/Ergo.Native
dotnet publish -c Release -r win-x64
```

Copy the resulting `Ergo.Native.dll` (and dependencies like `onnxruntime.dll` and `OpenCvSharpExtern.dll`) to the Flutter project's build directory or ensure they are reachable in the system path.

### Running the App

```powershell
cd app
flutter run -d windows
```

## Documentation

- [Architecture Overview](docs/ARCHITECTURE.md)
- [Posture Logic Engine](docs/POSTURE_ENGINE.md)

## Security

ERGO uses **SQLCipher** to encrypt the local database. The encryption key is securely managed using platform-specific storage (Windows Vault via `win_vault.dart`).
