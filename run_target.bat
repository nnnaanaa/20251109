@echo off
title PowerShell経由の自動入力スクリプト

echo.
echo === input_p_target.bat を PowerShell経由で自動実行します ===
echo.

:: 回答リスト
set "ANSWERS=2025/12/10|名古屋|神奈川|"

set birthdate=2025/12/11
set birthplace=名古屋
set workplace=神奈川

:: PowerShellで回答文字列をパイプで渡し、input_p_target.batを実行
rem powershell -Command "& { '%ANSWERS%' -replace '\|', \"`n\" | .\input_p_target.bat }"
call input_p_target.bat < 自動応答.txt

echo.
echo === 自動入力処理が完了しました ===