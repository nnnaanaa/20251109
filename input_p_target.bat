@echo off
title ユーザー情報入力フォーム

echo.
echo === ユーザー情報入力 ===
echo.

:: 1. 生年月日 (例: 1990/01/01) の入力
set /p "birthdate=生年月日 (例: YYYY/MM/DD) を入力してください: "

:: 2. 出身地の入力
set /p "birthplace=出身地を入力してください: "

:: 3. 勤務地の入力
set /p "workplace=勤務地を入力してください: "

echo === 入力内容の確認 ===
echo 生年月日: %birthdate% 
echo 出身地: %birthplace%
echo 勤務地: %workplace%

exit /b 0