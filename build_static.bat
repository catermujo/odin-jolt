@echo off

setlocal EnableDelayedExpansion

set "VENDOR_WINDOWS_ARCH=%VSCMD_ARG_TGT_ARCH%"
if not defined VENDOR_WINDOWS_ARCH set "VENDOR_WINDOWS_ARCH=%PROCESSOR_ARCHITECTURE%"
if /I "%VENDOR_WINDOWS_ARCH%"=="AMD64" set "VENDOR_WINDOWS_ARCH=x64"
if /I "%VENDOR_WINDOWS_ARCH%"=="ARM64" set "VENDOR_WINDOWS_ARCH=arm64"
if /I "%VENDOR_WINDOWS_ARCH%"=="X86" set "VENDOR_WINDOWS_ARCH=x64"

set "JOLT_DIR=joltc\JoltPhysics"
set "BUILD_DIR=joltc\build_static"
set "OUTPUT_DIR=windows_%VENDOR_WINDOWS_ARCH%"

if not exist "%JOLT_DIR%" (
    git clone --recurse-submodules https://github.com/jrouwe/JoltPhysics -b v5.6.0 --depth=1 "%JOLT_DIR%"
    if errorlevel 1 exit /b 1
)

echo Configuring static joltc...
cmake -S joltc -B "%BUILD_DIR%" -A %VENDOR_WINDOWS_ARCH% -DCPP_EXCEPTIONS_ENABLED=OFF -DCPP_RTTI_ENABLED=OFF -DJPH_BUILD_SHARED=OFF -DJPH_USE_DX12=OFF -DJPH_USE_VK=OFF -DJPH_USE_MTL=OFF -DJPH_USE_CPU_COMPUTE=OFF -DJPH_INSTALL=OFF -DJPH_SAMPLES=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded
if errorlevel 1 exit /b 1

echo Building static joltc...
cmake --build "%BUILD_DIR%" --config Release -j%NUMBER_OF_PROCESSORS%
if errorlevel 1 exit /b 1

if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

set "JOLTC_LIB="
for /r "%BUILD_DIR%" %%F in (joltc.lib) do if not defined JOLTC_LIB set "JOLTC_LIB=%%F"
set "JOLT_LIB="
for /r "%BUILD_DIR%" %%F in (Jolt.lib) do if not defined JOLT_LIB set "JOLT_LIB=%%F"

if not defined JOLTC_LIB (
    echo ERROR: static joltc.lib not found
    exit /b 1
)
if not defined JOLT_LIB (
    echo ERROR: static Jolt.lib not found
    exit /b 1
)

lib.exe /OUT:"%OUTPUT_DIR%\joltc_static.lib" "%JOLTC_LIB%" "%JOLT_LIB%"
if errorlevel 1 exit /b 1

echo Static joltc build completed successfully!
