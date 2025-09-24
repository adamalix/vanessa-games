#!/bin/zsh

echo "🔍 Snapshot Testing Environment Debug Script"
echo "=============================================="
echo ""

# Environment Information
echo "📋 Environment Variables:"
echo "CI: ${CI:-'not set'}"
echo "CI_XCODE_CLOUD: ${CI_XCODE_CLOUD:-'not set'}"
echo "CI_PRIMARY_REPOSITORY_PATH: ${CI_PRIMARY_REPOSITORY_PATH:-'not set'}"
echo "CI_DERIVED_DATA_PATH: ${CI_DERIVED_DATA_PATH:-'not set'}"
echo "CI_RESULT_BUNDLE_PATH: ${CI_RESULT_BUNDLE_PATH:-'not set'}"
echo "CI_BUILD_NUMBER: ${CI_BUILD_NUMBER:-'not set'}"
echo "CI_BRANCH: ${CI_BRANCH:-'not set'}"
echo "CI_COMMIT: ${CI_COMMIT:-'not set'}"
echo ""

# System Information
echo "🖥️  System Information:"
echo "macOS Version: $(sw_vers -productVersion)"
echo "Xcode Version: $(xcodebuild -version | head -1)"
echo "Available Simulators:"
xcrun simctl list devices available | grep -E "(iPhone|iPad)" | head -10
echo ""

# Workspace Information
echo "📁 Workspace Structure:"
echo "Current working directory: $(pwd)"
echo "Workspace contents:"
if [[ -d "/Volumes/workspace" ]]; then
    ls -la /Volumes/workspace/ | head -10
else
    echo "❌ /Volumes/workspace not found"
fi
echo ""

# Repository Structure
if [[ -n "$CI_PRIMARY_REPOSITORY_PATH" && -d "$CI_PRIMARY_REPOSITORY_PATH" ]]; then
    echo "📦 Repository Structure:"
    echo "Repository path: $CI_PRIMARY_REPOSITORY_PATH"
    echo "VanessaGames directory contents:"
    ls -la "$CI_PRIMARY_REPOSITORY_PATH/VanessaGames/" | head -10
    echo ""

    echo "🗂️  Existing Snapshot Directories:"
    find "$CI_PRIMARY_REPOSITORY_PATH" -type d -name "__Snapshots__" 2>/dev/null | head -10
    echo ""

    echo "📸 Existing Snapshot Files:"
    find "$CI_PRIMARY_REPOSITORY_PATH" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) 2>/dev/null | wc -l | xargs echo "Total image files found:"
    find "$CI_PRIMARY_REPOSITORY_PATH" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) 2>/dev/null | head -5
    echo ""
else
    echo "❌ Repository path not accessible"
    echo ""
fi

# Derived Data Information
if [[ -n "$CI_DERIVED_DATA_PATH" && -d "$CI_DERIVED_DATA_PATH" ]]; then
    echo "🏗️  Derived Data Information:"
    echo "Derived data path: $CI_DERIVED_DATA_PATH"
    echo "Size: $(du -sh "$CI_DERIVED_DATA_PATH" 2>/dev/null | cut -f1)"
    echo ""
else
    echo "❌ Derived data path not accessible"
    echo ""
fi

# Test Results Information
if [[ -n "$CI_RESULT_BUNDLE_PATH" && -d "$CI_RESULT_BUNDLE_PATH" ]]; then
    echo "📊 Test Results Bundle:"
    echo "Result bundle path: $CI_RESULT_BUNDLE_PATH"
    echo "Bundle contents:"
    ls -la "$CI_RESULT_BUNDLE_PATH" 2>/dev/null | head -5
    echo ""

    # Try to extract test information
    if command -v xcresulttool >/dev/null 2>&1; then
        echo "🔍 Extracting test information..."
        xcresulttool get --format json --path "$CI_RESULT_BUNDLE_PATH" 2>/dev/null | jq '.actions[].buildResult.testsRef' 2>/dev/null || echo "Could not extract test details"
    else
        echo "⚠️  xcresulttool not available"
    fi
    echo ""
else
    echo "❌ Test result bundle not accessible"
    echo ""
fi

# Memory and Disk Information
echo "💾 System Resources:"
echo "Available disk space:"
df -h /Volumes/workspace 2>/dev/null || df -h /
echo ""
echo "Memory usage:"
vm_stat | head -5
echo ""

# Permissions Check
echo "🔐 Permissions Check:"
echo "Can write to workspace: $(touch /Volumes/workspace/test_write_permission 2>/dev/null && echo '✅ Yes' && rm /Volumes/workspace/test_write_permission || echo '❌ No')"
if [[ -n "$CI_PRIMARY_REPOSITORY_PATH" ]]; then
    echo "Can read repository: $(test -r "$CI_PRIMARY_REPOSITORY_PATH" && echo '✅ Yes' || echo '❌ No')"
fi
echo ""

# Simulator Information
echo "📱 Simulator Status:"
echo "Currently running simulators:"
xcrun simctl list devices | grep "Booted" || echo "No simulators currently booted"
echo ""

# Swift Testing Environment
echo "🧪 Swift Testing Environment:"
echo "Available testing frameworks:"
find /Applications/Xcode.app -name "*Testing*" 2>/dev/null | head -3 || echo "Could not locate testing frameworks"
echo ""

echo "✅ Debug information collection completed"
echo ""
echo "💡 Tips for debugging snapshot issues:"
echo "1. Check that CI environment variables are properly set"
echo "2. Verify simulator is available and can render views"
echo "3. Ensure snapshot directories have proper write permissions"
echo "4. Check if derived data path is accessible for test artifacts"
echo "5. Verify that test result bundles are being generated"
echo ""
