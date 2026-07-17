@echo off
setlocal enabledelayedexpansion

set "DIR=%~dp0"
set "APP_DIR=%DIR%appLogTic"
set "OUT_DIR=%DIR%out"

:: Configurar JAVA_HOME con la ultima version de OpenJDK (Temurin 21)
if not defined JAVA_HOME (
    if exist "C:\Program Files\Eclipse Adoptium\jdk-21.0.11.10-hotspot\bin\java.exe" (
        set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-21.0.11.10-hotspot"
    ) else if exist "%LOCALAPPDATA%\Eclipse Adoptium\jdk-21.0.11.10-hotspot\bin\java.exe" (
        set "JAVA_HOME=%LOCALAPPDATA%\Eclipse Adoptium\jdk-21.0.11.10-hotspot"
    )
)
if defined JAVA_HOME (
    set "PATH=%JAVA_HOME%\bin;%PATH%"
    echo [+] JAVA_HOME: %JAVA_HOME%
)
echo =====================================
echo [*] Construyendo appLogTic (APK Debug)
echo =====================================

set "FLUTTER_CMD=C:\Users\r.paez\flutter\bin\flutter.bat"
echo [+] Usando Flutter SDK local: !FLUTTER_CMD!

:: Limpieza y preparación de la carpeta de salida
if exist "%OUT_DIR%" rmdir /S /Q "%OUT_DIR%"
mkdir "%OUT_DIR%"

cd /d "%APP_DIR%"

echo [*] Obteniendo dependencias...
call %FLUTTER_CMD% pub get

echo [*] Compilando APK Debug...
call %FLUTTER_CMD% build apk --debug

:: Copiar el APK generado a la carpeta de salida
copy /Y "build\app\outputs\flutter-apk\app-debug.apk" "%OUT_DIR%\appLogTic-debug.apk" >nul

echo =====================================
echo [~] Proceso completado exitosamente.
echo Puedes encontrar tu APK en: %OUT_DIR%\appLogTic-debug.apk
echo =====================================
