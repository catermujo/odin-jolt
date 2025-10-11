@echo off

setlocal EnableDelayedExpansion

set vendor_dir=joltc\JoltPhysics
set binaries_dir=build

if not exist joltc\JoltPhysics\NUL (
    git clone --recurse-submodules https://github.com/jrouwe/JoltPhysics -b v5.3.0 --depth=1 %vendor_dir%
)

echo Configuring build...
cmake -S %vendor_dir%\Build -B %binaries_dir% -DCPP_EXCEPTIONS_ENABLED=OFF -DCPP_RTTI_ENABLED=OFF -DTARGET_UNIT_TESTS=OFF -DTARGET_HELLO_WORLD=OFF -DTARGET_PERFORMANCE_TEST=OFF -DTARGET_SAMPLES=OFF -DTARGET_VIEWER=OFF

echo Building project...
cmake --build %binaries_dir% --config Release

copy /y %binaries_dir%\Release\Jolt.lib joltc.lib
copy /y %binaries_dir%\Release\Jolt.pdb joltc.pdb

echo Build completed successfully!
