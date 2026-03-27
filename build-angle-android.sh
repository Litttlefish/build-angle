#!/bin/bash
set -e

# Get current directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

# Setup ANGLE if needed
if [ ! -d "angle" ]; then
    source ./setup-angle-linux.sh
else
    # Add depot_tools to PATH
    export PATH="$PATH:$SCRIPT_DIR/depot_tools"
fi

# Go to ANGLE directory
cd angle

# Common GN args for all iOS builds
COMMON_ARGS='
    android_static_analysis="on"
    target_os="android"
    target_cpu="arm"
    is_debug=false
    angle_enable_cl=true
    dcheck_always_on=true
    is_component_build=false
    strip_debug_info=false
    symbol_level=0
    angle_build_tests=false
    is_official_build=true
    build_with_chromium=false
    is_clang=true
    clang_use_chrome_plugins=false
'
    # use_custom_libcxx=false


# Build for Android x64
echo "Building ANGLE for Android x64..."
gn gen out/Android --args="$COMMON_ARGS"

# autoninja -C out/Android
m ANGLE_settings

# Return to script directory
cd $SCRIPT_DIR

echo "."
echo "Android builds complete! Files are available in:"
echo "  - ./out/Android"
