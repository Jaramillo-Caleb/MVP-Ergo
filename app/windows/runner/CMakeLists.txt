cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the build version.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

# Disable Windows macros that collide with C++ standard library functions.
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

# Add dependency libraries and include directories. Add any application-specific
# dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)

# Se define la ruta de la DLL 
set(ERGO_NATIVE_DLL_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../../native/Ergo.Native/bin/Release/net9.0/win-x64/native/Ergo.Native.dll")

# 2. Comando para copiar la DLL automáticamente después de compilar
add_custom_command(
    TARGET ${BINARY_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    "${ERGO_NATIVE_DLL_PATH}"
    "$<TARGET_FILE_DIR:${BINARY_NAME}>/Ergo.Native.dll"
    COMMENT "Copiando Ergo.Native.dll al directorio de ejecucion..."
)

# Copiar el modelo ONNX 
set(ERGO_MODEL_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../../assets/models/pose_landmark_lite.onnx")

add_custom_command(
    TARGET ${BINARY_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    "${ERGO_MODEL_PATH}"
    "$<TARGET_FILE_DIR:${BINARY_NAME}>/pose_landmark_lite.onnx"
    COMMENT "Copiando modelo ONNX al directorio de ejecucion..."
)

# Copiar las DLLs de SQLCipher al directorio de salida
set(SQLCIPHER_DLLS 
    "${CMAKE_CURRENT_SOURCE_DIR}/../../sqlcipher.dll"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../libcrypto-1_1-x64.dll" 
)

foreach(dll ${SQLCIPHER_DLLS})
    add_custom_command(
        TARGET ${BINARY_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${dll}"
        "$<TARGET_FILE_DIR:${BINARY_NAME}>"
    )
endforeach()