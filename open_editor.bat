@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

set GODOT_EXE=Godot_v4.3-stable_win64.exe

if not exist "%GODOT_EXE%" (
    echo ========================================================
    echo [MMA-Online] Godot 4.3 executable not found locally.
    echo Auto-downloading Godot 4.3 Stable portable (official CDN)...
    echo ========================================================
    powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Write-Host 'Downloading Godot 4.3...'; (New-Object Net.WebClient).DownloadFile('https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_win64.exe.zip', 'godot.zip'); Write-Host 'Extracting...'; Expand-Archive -Path 'godot.zip' -DestinationPath '.' -Force; Remove-Item 'godot.zip'"
)

if exist "%GODOT_EXE%" (
    echo Opening Godot Editor for MMA-Online...
    start "" "%~dp0%GODOT_EXE%" -e --path "%~dp0."
) else (
    echo [ERROR] Failed to obtain Godot 4.3. Please download from https://godotengine.org/download
    pause
)
