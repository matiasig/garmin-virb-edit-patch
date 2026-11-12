@echo off
chcp 65001 >nul
title Parche Garmin VIRB Edit 5.4.3 - Reparacion de Mapa y Sincronizacion GPS

:: Comprobar permisos de Administrador y auto-elevar si es necesario
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Solicitando permisos de Administrador para actualizar Garmin VIRB Edit...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "PATCH_DIR=%~dp0Parche_Archivos"
set "TARGET_DIR=C:\Program Files\Garmin\VIRB Edit"

if not exist "%TARGET_DIR%\VirbEdit.exe" (
    if exist "C:\Program Files (x86)\Garmin\VIRB Edit\VirbEdit.exe" (
        set "TARGET_DIR=C:\Program Files (x86)\Garmin\VIRB Edit"
    )
)

echo ============================================================================
echo   PARCHE GARMIN VIRB EDIT 5.4.3 - MAPA Y SINCRONIZACION GPS (G-METRIX)
echo ============================================================================
echo.

:: Cerrar VIRB Edit si esta abierto
taskkill /F /IM VirbEdit.exe >nul 2>&1

if exist "%TARGET_DIR%\VirbEdit.exe" (
    echo [1/3] Creando copia de seguridad del ejecutable original...
    if not exist "%TARGET_DIR%\VirbEdit.exe.bak" (
        copy /Y "%TARGET_DIR%\VirbEdit.exe" "%TARGET_DIR%\VirbEdit.exe.bak" >nul
    )
    if not exist "%TARGET_DIR%\VirbEdit.exe.config.bak" (
        copy /Y "%TARGET_DIR%\VirbEdit.exe.config" "%TARGET_DIR%\VirbEdit.exe.config.bak" >nul
    )

    echo [2/3] Copiando VirbEdit.exe parcheado y el nuevo motor de mapas local ^(maps.html^)...
    copy /Y "%PATCH_DIR%\VirbEdit.exe" "%TARGET_DIR%\VirbEdit.exe" >nul
    copy /Y "%PATCH_DIR%\VirbEdit.exe.config" "%TARGET_DIR%\VirbEdit.exe.config" >nul
    copy /Y "%PATCH_DIR%\maps.html" "%TARGET_DIR%\maps.html" >nul

    echo [3/3] Parche aplicado correctamente en:
    echo       "%TARGET_DIR%"
    echo.
    echo Ya puedes abrir Garmin VIRB Edit normalmente desde tu acceso directo.
) else (
    echo [AVISO] No se encontro una instalacion en "C:\Program Files\Garmin\VIRB Edit".
    echo         Puedes ejecutar Garmin VIRB Edit directamente sin instalar desde:
    echo         "%~dp0VIRB_Edit_Parcheado\VirbEdit.exe"
)

echo.
pause
