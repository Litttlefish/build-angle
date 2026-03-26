@echo off
setlocal enabledelayedexpansion

:: Get current directory
set SCRIPT_DIR=%~dp0
cd %SCRIPT_DIR%

:: Set environment variables for using local toolchain
set DEPOT_TOOLS_WIN_TOOLCHAIN=0

:: Setup ANGLE if needed
if not exist angle (
    echo ANGLE not found. Running setup script...
    call setup-angle-windows.bat
    if %ERRORLEVEL% NEQ 0 (
        echo Setup failed. Exiting.
        exit /b 1
    )
)

:: Add depot_tools to PATH
set PATH=%SCRIPT_DIR%depot_tools;%PATH%

:: Go to ANGLE directory
cd angle

:: Create the chrome/VERSION file that is required by compute_build_timestamp.py
if not exist chrome\VERSION (
    echo Creating mock chrome VERSION file...
    mkdir chrome 2>nul
    (
        echo MAJOR=1
        echo MINOR=0
        echo BUILD=0
        echo PATCH=0
    ) > chrome\VERSION
)

:: Common GN args for all Windows builds
set COMMON_ARGS=^
    android_static_analysis = on ^
    target_os = android ^
    target_cpu = arm ^
    is_debug=false ^
    angle_enable_cl = true ^
    dcheck_always_on = true ^
    is_component_build = true ^
    symbol_level=0 ^
    use_reclient = false ^
    use_siso = true
    angle_standalone=true ^
    angle_build_tests=false ^
    chrome_pgo_phase=0 ^
    is_official_build=true ^
    use_custom_libcxx=false ^
    strip_debug_info=true ^
    build_with_chromium=false ^
    is_clang=true ^
    clang_use_chrome_plugins=false

:: Build for Android x64
echo Building ANGLE for Android x64...
call gn gen out/Android --args="%COMMON_ARGS%"
if %ERRORLEVEL% NEQ 0 (
    echo Failed to generate x64 build files. Exiting.
    exit /b 1
)

call ninja -C out/Android
if %ERRORLEVEL% NEQ 0 (
    echo Failed to build x64 version. Exiting.
    exit /b 1
)

:: Return to script directory
cd %SCRIPT_DIR%

echo.
echo Android builds complete! Files are available in:
echo   - .\out/Android
