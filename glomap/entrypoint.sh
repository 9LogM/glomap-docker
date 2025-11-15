#!/bin/bash

set -e

# --- Configuration ---
SCENE_NAME=my_scene
CAPTURE_FRAMERATE=30  # Only used for .bag conversion
FPS_EXTRACT=2

# --- Paths ---
INPUT_PATH=$(find /data/input -type f -name "*.bag" -o -name "*.mp4" | head -n 1)
PROJECT_DIR="/data/output/${SCENE_NAME}"
IMAGE_DIR="${PROJECT_DIR}/input"

# --- Video Conversion ---
if [[ "${INPUT_PATH}" == *.bag ]]; then
    echo "--- .bag file detected. Starting full conversion workflow. ---"
    TEMP_FRAME_DIR="${PROJECT_DIR}/temp_frames"

    mkdir -p "${IMAGE_DIR}" "${TEMP_FRAME_DIR}"
    
    rs-convert -i "${INPUT_PATH}" -p "${TEMP_FRAME_DIR}/frame"
    ffmpeg \
        -framerate "${CAPTURE_FRAMERATE}" \
        -pattern_type glob -i "${TEMP_FRAME_DIR}/frame_Color_*.png" \
        -vf "fps=${FPS_EXTRACT}" \
        -qscale:v 1 \
        -qmin 1 \
        "${IMAGE_DIR}/frame_%04d.jpg"
    rm -rf "${TEMP_FRAME_DIR}"

elif [[ "${INPUT_PATH}" == *.mp4 ]]; then
    echo "--- .mp4 file detected. Starting standard extraction. ---"
    
    mkdir -p "${IMAGE_DIR}"

    ffmpeg \
        -i "${INPUT_PATH}" \
        -vf "fps=${FPS_EXTRACT}" \
        -pix_fmt yuvj444p \
        -qscale:v 1 -qmin 1 \
        "${IMAGE_DIR}/frame_%04d.jpg"
else
    echo "Error: Input file is not a valid .bag or .mp4 file."
    exit 1
fi
echo "--- Frame extraction complete. ---"