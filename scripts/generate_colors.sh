#!/usr/bin/env bash

IMAGE_PATH="$1"
OUTPUT_PATH="$2"

if [ -z "$IMAGE_PATH" ] || [ -z "$OUTPUT_PATH" ]; then
    echo "Usage: $0 <image_path> <output_path>"
    exit 1
fi

if [ ! -f "$IMAGE_PATH" ]; then
    echo "Error: Image file not found at $IMAGE_PATH"
    exit 1
fi

echo "Generating colors from: $IMAGE_PATH"

OUTPUT_DIR=$(dirname "$OUTPUT_PATH")
mkdir -p "$OUTPUT_DIR"

MIME_TYPE=$(file -b --mime-type "$IMAGE_PATH")
TEMP_IMG=""

if [[ "$MIME_TYPE" == "image/gif" ]]; then
    echo "Detected GIF. Extracting first frame..."
    TEMP_IMG="/tmp/matugen_temp_$(date +%s).png"

    if command -v magick &> /dev/null; then
        magick "$IMAGE_PATH[0]" "$TEMP_IMG"
    elif command -v convert &> /dev/null; then
        convert "$IMAGE_PATH[0]" "$TEMP_IMG"
    else
        echo "Error: ImageMagick (magick/convert) not found. Cannot process GIF."
        exit 1
    fi
    TARGET_IMAGE="$TEMP_IMG"
else
    TARGET_IMAGE="$IMAGE_PATH"
fi

if ! matugen image "$TARGET_IMAGE" -t scheme-vibrant --json hex --dry-run > "$OUTPUT_PATH"; then
    echo "Error: matugen failed to generate colors."
    [ -n "$TEMP_IMG" ] && rm -f "$TEMP_IMG"
    exit 1
fi

[ -n "$TEMP_IMG" ] && rm -f "$TEMP_IMG"

echo "Successfully generated colors at $OUTPUT_PATH"

PYTHON_SCRIPT="$(dirname "$0")/generate_terminal_colors.py"
if [ -f "$PYTHON_SCRIPT" ]; then
    echo "Running terminal color generation..."
    python3 "$PYTHON_SCRIPT" "$OUTPUT_PATH"
else
    echo "Warning: generate_terminal_colors.py not found at $PYTHON_SCRIPT"
fi

exit 0
