@echo off
setlocal enabledelayedexpansion

set "DIR=%~dp0"
set "APP_DIR=%DIR%appLogTic"
set "OUT_DIR=%DIR%out"

echo =====================================
echo [*] Construyendo appLogTic (APK Debug)
echo =====================================

:: Preparar entorno virtual (Flutter SDK temporal si no existe)
set "FLUTTER_CMD=flutter"
where flutter >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [!] flutter no esta instalado en el PATH. Preparando entorno temporal...
    if not exist "%TEMP%\flutter" (
        echo [*] Descargando Flutter SDK ^(stable^)...
        git clone https://github.com/flutter/flutter.git -b stable "%TEMP%\flutter"
    )
    set "PATH=%PATH%;%TEMP%\flutter\bin"
    set "FLUTTER_CMD=%TEMP%\flutter\bin\flutter.bat"
    echo [+] Usando Flutter SDK en !FLUTTER_CMD!
    
    :: Precache flutter artifacts
    call !FLUTTER_CMD! precache --android
)

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
