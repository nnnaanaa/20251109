@echo off
setlocal enabledelayedexpansion

set "TITLE=サービス状況確認スクリプト"
set "SCRIPT_DIR=%~dp0"
set "CHECK_FILE=%SCRIPT_DIR%%~n0.txt"

@REM echo.
@REM echo --- check_services.txt に基づくサービス状況確認 ---
@REM echo.

:: check_services.txt を読み込み、サービスごとに処理
for /f "usebackq tokens=1,2 delims=," %%S in ("%CHECK_FILE%") do (
    set "ServiceName=%%S"
    set "ServiceStatus=%%T"
    @REM echo ServiceName: !ServiceName!
    @REM echo ServiceStatus: !ServiceStatus!

    :: 空行やコメント行 (#で始まる行) をスキップ
    if not "!ServiceName!"=="" if not "!ServiceName:~0,1!"=="#" (
        echo [ServiceName:!ServiceName!]
        
        @REM :: サービスの状態を確認し、STATE行のみを抽出して表示
        @REM sc query "!ServiceName!" | find "STATE"

        for /f "tokens=4 delims= " %%A in ('sc query "!ServiceName!" ^| find "STATE"') do (
            set "StateStatusNow=%%A"
            set "StateStatusNow=!StateStatusNow: =!"
            if "!StateStatusNow!"=="!ServiceStatus!" (
                echo -- 状態一致: !ServiceStatus! --
            ) else (
                echo -- 状態不一致: 期待値=!ServiceStatus!, 現在値=!StateStatusNow! --
            )
        )
        :: サービスが見つからない場合に備えてエラーレベルをチェック
        if errorlevel 1 (
            echo    -- サービスが見つからないか、エラーが発生しました --
        )
    )
)

@REM echo --- 確認完了 ---
exit /b 0