@echo off
setlocal enabledelayedexpansion

rem --- 基本設定 ---
set target_folder=D:\TargetFolder\
set config_folder=D:\TargetFolder\conf\
set phase1_filename=aaa.txt
set phase2_filename=bbb.txt

set phase1_folder_name=
set phase2_folder_name=

rem --- 設定ファイルからフォルダ名を取得 ---
for /F "usebackq delims=" %%A in ( `type %config_folder%%phase1_filename%`) do (
    set phase1_folder_name=%%A
)
for /F "usebackq delims=" %%A in ( `type %config_folder%%phase2_filename%`) do (
    set phase2_folder_name=%%A
)

rem 末尾に必ず \ を付けておくことで、相対パス置換を確実にします
set base_path=%target_folder%%phase1_folder_name%\
set compare_path=%target_folder%%phase2_folder_name%\

rem --------------------------------------------------------------------------------
rem 1. タイムスタンプの取得と出力フォルダの設定
rem --------------------------------------------------------------------------------

rem 日付と時刻を取得し、yyyymmddHHmmss 形式に変換
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (
    set datestr=%%c%%a%%b
)
for /f "tokens=1-3 delims=:. " %%a in ('time /t') do (
    set timestr=%%a%%b%%c
)

set "timestamp_folder_name=%datestr%%timestr%_%phase1_folder_name%_vs_%phase2_folder_name%"
set "output_root_folder=%target_folder%%timestamp_folder_name%"

rem 出力フォルダを作成
mkdir "%output_root_folder%"

rem サマリーファイル名を設定
set "summary_file=%output_root_folder%\diff_files_report.txt"
echo. > "%summary_file%"
echo --- フォルダ比較サマリー: %phase1_folder_name% vs %phase2_folder_name% --- >> "%summary_file%"
echo 出力フォルダ: "%output_root_folder%" >> "%summary_file%"
echo. >> "%summary_file%"

rem --------------------------------------------------------------------------------
rem 2. 比較処理 (Phase 1 基準)
rem --------------------------------------------------------------------------------

rem **FOR /R を使用して安定したファイル走査に戻します**
for /R "%base_path%" %%F in (*) do (
    rem %%F はフルパス。ベースパスを削除して相対パスを取得
    set "relative_path=%%F"
    set "relative_path=!relative_path:%base_path%=!"
    
    rem 比較対象のフルパスを構築
    set "compare_file_full_path=%compare_path%!relative_path!"
    
    rem ファイル名と拡張子のみを取得し、ログファイル名を作成
    set "filename_ext=%%~nxF"
    set "diff_log_filename=DIFF_!filename_ext!.log"
    set "diff_log_path=%output_root_folder%\!diff_log_filename!"
    
    rem ファイルの存在チェック
    if exist "!compare_file_full_path!" (
        rem FCコマンドで内容比較を実行 (/L: テキスト比較, /N: 行番号表示)
        fc /L /N "%%F" "!compare_file_full_path!" > "!diff_log_path!"
        
        rem 戻り値（%ERRORLEVEL%）をチェック
        if errorlevel 1 (
            rem 差異がある場合
            echo [DIFFERENT] !relative_path! (詳細: !diff_log_path!) >> "%summary_file%"
        ) else ( rem **構文修正：閉じ括弧とelseを同一行に**
            rem 一致する場合、ログファイルを削除
            del "!diff_log_path!"
        )
    ) else ( rem **構文修正：閉じ括弧とelseを同一行に**
        rem compare_pathにファイルが存在しない場合 (phase1にのみ存在)
        echo [ONLY IN %phase1_folder_name%] !relative_path! >> "%summary_file%"
    )
)

rem --------------------------------------------------------------------------------
rem 3. 比較処理 (Phase 2 にのみ存在するファイル)
rem --------------------------------------------------------------------------------

rem phase2にのみ存在するファイルを探す
for /R "%compare_path%" %%G in (*) do (
    set "relative_path_2=%%G"
    set "relative_path_2=!relative_path_2:%compare_path%=!"
    
    set "base_file_full_path=%base_path%!relative_path_2!"
    
    rem base_pathにファイルが存在しないことをチェック
    if not exist "!base_file_full_path!" (
        echo [ONLY IN %phase2_folder_name%] !relative_path_2! >> "%summary_file%"
    )
)

echo. >> "%summary_file%"
echo --- 比較処理が完了しました --- >> "%summary_file%"
echo.
echo 比較結果のフォルダは "%output_root_folder%" に出力されました。
echo 詳細な差分内容は各 DIFF_*.log ファイルを確認してください。
pause