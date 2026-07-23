#!/usr/bin/env bash
set -euo pipefail

FORMS_DIR="J-Runner/Forms"

# Linux case-sensitivity workaround build script
SYMLINKS=(
    "$FORMS_DIR/CustomXeBuild.cs:$FORMS_DIR/CustomXebuild.cs"
    "$FORMS_DIR/CustomXeBuild.Designer.cs:$FORMS_DIR/CustomXebuild.Designer.cs"
    "$FORMS_DIR/CustomXeBuild.resx:$FORMS_DIR/CustomXebuild.resx"
    "$FORMS_DIR/DemoN_Uart.cs:$FORMS_DIR/demon_uart.cs"
    "$FORMS_DIR/DemoN_Uart.Designer.cs:$FORMS_DIR/demon_uart.Designer.cs"
    "$FORMS_DIR/DemoN_Uart.resx:$FORMS_DIR/demon_uart.resx"
    "$FORMS_DIR/CPUKeyGen.designer.cs:$FORMS_DIR/CPUKeyGen.Designer.cs"
    "$FORMS_DIR/XB1HDD.designer.cs:$FORMS_DIR/XB1HDD.Designer.cs"
)

cleanup() {
    echo "Cleaning up symlinks..."
    for entry in "${SYMLINKS[@]}"; do
        link="${entry%%:*}"
        if [ -L "$link" ]; then
            rm -f "$link"
        fi
    done
}

# Always clean up on exit, even on error or Ctrl+C
trap cleanup EXIT

echo "Creating case-correcting symlinks for Linux..."
for entry in "${SYMLINKS[@]}"; do
    link="${entry%%:*}"
    target="${entry##*:}"
    # Only create if the real file exists and the symlink doesn't yet
    if [ -f "$target" ] && [ ! -e "$link" ]; then
        ln -sf "$(basename "$target")" "$link"
        echo "  $link -> $target"
    fi
done

echo ""
echo "Building JRunner.sln (Debug)..."
msbuild JRunner.sln /p:Configuration=Debug 2>errors.log

echo ""
echo "Build complete. Any errors/warnings are in errors.log"
