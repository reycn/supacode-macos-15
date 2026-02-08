#!/bin/bash
set -euo pipefail

# Filter out conda/miniforge toolchains from PATH that interfere with Xcode builds
export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v miniforge3 | grep -v condabin | tr '\n' ':' | sed 's/:$//')

# Unset conda toolchain variables that interfere with Xcode builds
unset LDFLAGS LD CC CXX CPP AR LIPO RANLIB STRIP NM CFLAGS CXXFLAGS CPPFLAGS 2>/dev/null || true
unset CONDA_TOOLCHAIN_HOST CONDA_TOOLCHAIN_BUILD _CONDA_PYTHON_SYSCONFIGDATA_NAME 2>/dev/null || true

# Configuration
APP_NAME="Supacode"
APP_PATH="/Applications/${APP_NAME}.app"

echo "==> Quitting ${APP_NAME} if running..."
if pgrep -x "${APP_NAME}" > /dev/null 2>&1; then
    osascript -e "tell application \"${APP_NAME}\" to quit" 2>/dev/null || true
    # Wait for the app to quit (max 5 seconds)
    for i in {1..10}; do
        if ! pgrep -x "${APP_NAME}" > /dev/null 2>&1; then
            echo "    ${APP_NAME} has quit"
            break
        fi
        sleep 0.5
    done
    # Force kill if still running
    if pgrep -x "${APP_NAME}" > /dev/null 2>&1; then
        echo "    Force killing ${APP_NAME}..."
        pkill -9 -x "${APP_NAME}" || true
    fi
else
    echo "    ${APP_NAME} is not running"
fi

echo "==> Building ${APP_NAME}..."
make build-app

echo "==> Installing to /Applications..."
make install-dev-build

echo "==> Launching ${APP_NAME}..."
open "${APP_PATH}"

echo "==> Done!"
