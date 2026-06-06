@echo off
setlocal
cd /d "%~dp0"

echo ========================================
echo  Servidor MME INVENTARI
echo ========================================
echo.
echo Iniciando arranque limpio de backend + frontend...

powershell -NoProfile -ExecutionPolicy Bypass -File ".\scripts\start-clean.ps1"

endlocal