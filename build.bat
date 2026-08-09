@echo off

setlocal EnableDelayedExpansion

set "VENDOR_WINDOWS_ARCH=%VSCMD_ARG_TGT_ARCH%"
if not defined VENDOR_WINDOWS_ARCH set "VENDOR_WINDOWS_ARCH=%PROCESSOR_ARCHITECTURE%"
if /I "%VENDOR_WINDOWS_ARCH%"=="AMD64" set "VENDOR_WINDOWS_ARCH=x64"
if /I "%VENDOR_WINDOWS_ARCH%"=="ARM64" set "VENDOR_WINDOWS_ARCH=arm64"
if /I "%VENDOR_WINDOWS_ARCH%"=="X86" set "VENDOR_WINDOWS_ARCH=x64"

set "JOLT_DIR=joltc\JoltPhysics"
set "BUILD_DIR=joltc\build_shared"
set "OUTPUT_DIR=windows_%VENDOR_WINDOWS_ARCH%"

if not exist "%JOLT_DIR%" (
    git clone --recurse-submodules https://github.com/jrouwe/JoltPhysics -b v5.6.0 --depth=1 "%JOLT_DIR%"
    if errorlevel 1 exit /b 1
)

echo Configuring shared joltc...
cmake -S joltc -B "%BUILD_DIR%" -A %VENDOR_WINDOWS_ARCH% -DCPP_EXCEPTIONS_ENABLED=OFF -DCPP_RTTI_ENABLED=OFF -DJPH_BUILD_SHARED=ON -DJPH_USE_DX12=OFF -DJPH_USE_VK=OFF -DJPH_USE_MTL=OFF -DJPH_USE_CPU_COMPUTE=OFF -DJPH_INSTALL=OFF -DJPH_SAMPLES=OFF -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 exit /b 1

echo Building shared joltc...
cmake --build "%BUILD_DIR%" --config Release -j%NUMBER_OF_PROCESSORS%
if errorlevel 1 exit /b 1

if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

set "JOLTC_DLL="
for /r "%BUILD_DIR%" %%F in (joltc.dll) do if exist "%%F" if not defined JOLTC_DLL set "JOLTC_DLL=%%F"
set "JOLTC_LIB="
for /r "%BUILD_DIR%" %%F in (joltc.lib) do if exist "%%F" if not defined JOLTC_LIB set "JOLTC_LIB=%%F"

if not defined JOLTC_DLL (
    echo ERROR: shared joltc.dll not found
    exit /b 1
)
if not defined JOLTC_LIB (
    echo ERROR: shared joltc.lib not found
    exit /b 1
)

copy /y "%JOLTC_DLL%" "%OUTPUT_DIR%\joltc.dll" >nul
copy /y "%JOLTC_LIB%" "%OUTPUT_DIR%\joltc.lib" >nul

echo Shared joltc build completed successfully!
