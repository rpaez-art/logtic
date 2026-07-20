@echo off
setlocal enabledelayedexpansion

set DIR=%~dp0
set APP_DIR=%DIR%appLogTic
set OUT_DIR=%DIR%out

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
echo [*] Construyendo appLogTic (Debug ^& Release Firmado)
echo =====================================

set FLUTTER_CMD=C:\Users\r.paez\flutter\bin\flutter.bat
echo [+] Usando Flutter SDK local: %FLUTTER_CMD%

if exist "%OUT_DIR%" rmdir /S /Q "%OUT_DIR%"
mkdir "%OUT_DIR%"

cd /d "%APP_DIR%"

echo [*] Limpiando proyecto...
call "%FLUTTER_CMD%" clean
echo [*] Obteniendo dependencias...
call "%FLUTTER_CMD%" pub get

echo [*] Compilando APK Debug...
call "%FLUTTER_CMD%" build apk --debug

if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    copy /Y "build\app\outputs\flutter-apk\app-debug.apk" "%OUT_DIR%\appLogTic-debug.apk" >nul
    echo [+] APK Debug generado: %OUT_DIR%\appLogTic-debug.apk
)

echo [*] Limpiando cache intermedia para Release...
call "%FLUTTER_CMD%" clean
call "%FLUTTER_CMD%" pub get

echo [*] Compilando APK Release Firmado...
call "%FLUTTER_CMD%" build apk --release

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy /Y "build\app\outputs\flutter-apk\app-release.apk" "%OUT_DIR%\appLogTic-release.apk" >nul
    echo [+] APK Release generado: %OUT_DIR%\appLogTic-release.apk
)

echo =====================================
echo [~] Proceso completado exitosamente.
echo Puedes encontrar tus APKs en:
echo  - Debug:   %OUT_DIR%\appLogTic-debug.apk
echo  - Release: %OUT_DIR%\appLogTic-release.apk
echo =====================================
