# Sample Build Script for Testing
# In a real scenario, this would invoke your actual build toolchain

Write-Host "================================"
Write-Host "Building Firmware"
Write-Host "================================"

# Create build directory
New-Item -ItemType Directory -Force -Path "build" | Out-Null

# Simulate build process
Write-Host "Compiling source files..."
Start-Sleep -Seconds 1

Write-Host "Linking firmware..."
Start-Sleep -Seconds 1

# Copy sample firmware (in real build, this would be generated)
Write-Host "Generating firmware binary..."
Copy-Item "sample_firmware.axf" "build/firmware.axf"

# Display build info
Write-Host ""
Write-Host "Build complete!"
Write-Host "Output: build/firmware.axf"
Get-Item "build/firmware.axf" | Format-List Name, Length, LastWriteTime

Write-Host ""
Write-Host "Build artifacts:"
Get-ChildItem "build" | Format-Table Name, Length, LastWriteTime
