#!/bin/bash
# Sample build script for testing
# In a real scenario, this would invoke your actual build toolchain

set -e

echo "================================"
echo "Building Firmware"
echo "================================"

# Create build directory
mkdir -p build

# Simulate build process
echo "Compiling source files..."
sleep 1

echo "Linking firmware..."
sleep 1

# Copy sample firmware (in real build, this would be generated)
echo "Generating firmware binary..."
cp sample_firmware.axf build/firmware.axf

# Display build info
echo ""
echo "Build complete!"
echo "Output: build/firmware.axf"
ls -lh build/firmware.axf

echo ""
echo "Firmware info:"
file build/firmware.axf || echo "File type: ELF/AXF binary"
