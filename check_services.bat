@echo off
setlocal enabledelayedexpansion

set "TITLE=サービス状況確認スクリプト"
set "SCRIPT_DIR=%~dp0"
set "CHECK_FILE=%SCRIPT_DIR%check_services.txt"

echo.
echo --- check_services.txt に基づくサービス状況確認 ---
echo.

:: check_services.txt を読み込み、サービスごとに処理
for /f "usebackq tokens=*" %%S in ("%CHECK_FILE%") do (
    set "ServiceName=%%S"
    
    :: 空行やコメント行 (#で始まる行) をスキップ
    if not "!ServiceName!"=="" if not "!ServiceName:~0,1!"=="#" (
        echo [ServiceName:!ServiceName!]
        
        :: サービスの状態を確認し、STATE行のみを抽出して表示
        sc query "!ServiceName!" | find "STATE"
        
        :: サービスが見つからない場合に備えてエラーレベルをチェック
        if errorlevel 1 (
            echo    -- サービスが見つからないか、エラーが発生しました --
        )
        echo.
    )
)

echo --- 確認完了 ---
exit /b 0