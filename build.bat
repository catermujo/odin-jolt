@echo off

setlocal EnableDelayedExpansion

if not exist joltc\JoltPhysics\NUL (
    git clone --recurse-submodules https://github.com/jrouwe/JoltPhysics -b v5.3.0 --depth=1 joltc\JoltPhysics
)

set binaries_dir=build

echo Configuring build...
cmake . -B %binaries_dir% -DJPH_BUILD_SHARED=OFF

echo Building project...
make -C %binaries_dir%

copy /y %binaries_dir%\lib\joltc.lib .\

echo Build completed successfully!
