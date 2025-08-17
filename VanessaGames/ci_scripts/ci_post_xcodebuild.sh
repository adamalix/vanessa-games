#!/bin/zsh

echo "Build completed successfully"

# Collection and archiving of snapshot test artifacts for inspection
echo "🔍 Collecting snapshot test artifacts..."

# Define paths
REPO_ROOT="$CI_PRIMARY_REPOSITORY_PATH"
WORKSPACE_ROOT="/Volumes/workspace"
SNAPSHOT_ARCHIVE_NAME="snapshot-artifacts-$(date +%Y%m%d-%H%M%S).tar.gz"
SNAPSHOT_ARCHIVE_PATH="$WORKSPACE_ROOT/$SNAPSHOT_ARCHIVE_NAME"

# Create a temporary directory for organizing artifacts
TEMP_ARTIFACTS_DIR="$WORKSPACE_ROOT/temp-artifacts"
mkdir -p "$TEMP_ARTIFACTS_DIR"

# Function to collect snapshots from a directory
collect_snapshots() {
    local source_dir="$1"
    local dest_dir="$2"

    if [[ -d "$source_dir" ]]; then
        echo "📁 Collecting snapshots from: $source_dir"

        # Create destination directory structure
        mkdir -p "$dest_dir"

        # Copy all snapshot files (.png, .jpeg, .jpg)
        find "$source_dir" -type f \( -name "*.png" -o -name "*.jpeg" -o -name "*.jpg" \) -print0 | \
        while IFS= read -r -d '' file; do
            # Preserve directory structure
            rel_path="${file#$source_dir/}"
            dest_file="$dest_dir/$rel_path"
            mkdir -p "$(dirname "$dest_file")"
            cp "$file" "$dest_file"
            echo "  ✅ Copied: $rel_path"
        done

        # Also copy any failure diff files
        find "$source_dir" -type f -name "*diff.png" -print0 | \
        while IFS= read -r -d '' file; do
            rel_path="${file#$source_dir/}"
            dest_file="$dest_dir/$rel_path"
            mkdir -p "$(dirname "$dest_file")"
            cp "$file" "$dest_file"
            echo "  🔴 Copied diff: $rel_path"
        done
    else
        echo "⚠️  Directory not found: $source_dir"
    fi
}

# Function to create environment info file
create_environment_info() {
    local info_file="$TEMP_ARTIFACTS_DIR/environment-info.txt"

    echo "📋 Creating environment info file..."
    cat > "$info_file" << EOF
Snapshot Test Environment Information
=====================================
Generated: $(date)
Build Number: ${CI_BUILD_NUMBER:-"N/A"}
Branch: ${CI_BRANCH:-"N/A"}
Commit: ${CI_COMMIT:-"N/A"}
Xcode Version: $(xcodebuild -version | head -1)
macOS Version: $(sw_vers -productVersion)
Simulator Runtime: ${SIMULATOR_RUNTIME_VERSION:-"N/A"}
Device Model: ${SIMULATOR_MODEL_IDENTIFIER:-"N/A"}

Collected Snapshot Locations:
EOF

    # List all collected snapshots
    find "$TEMP_ARTIFACTS_DIR" -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" | \
    sed "s|$TEMP_ARTIFACTS_DIR/||" | sort >> "$info_file"

    echo "✅ Environment info saved to environment-info.txt"
}

# Function to create test results summary
create_test_summary() {
    local summary_file="$TEMP_ARTIFACTS_DIR/test-summary.txt"

    echo "📊 Creating test summary..."
    cat > "$summary_file" << EOF
Snapshot Test Results Summary
============================
Generated: $(date)

Test Results:
EOF

    # Look for test result bundles
    if [[ -d "$CI_RESULT_BUNDLE_PATH" ]]; then
        echo "Test Result Bundle: $CI_RESULT_BUNDLE_PATH" >> "$summary_file"

        # Try to extract test info using xcresulttool if available
        if command -v xcresulttool >/dev/null 2>&1; then
            echo "Attempting to extract test results..." >> "$summary_file"
            xcresulttool get --format json --path "$CI_RESULT_BUNDLE_PATH" 2>/dev/null >> "$summary_file" || \
            echo "Could not extract detailed test results" >> "$summary_file"
        fi
    else
        echo "No result bundle found at: ${CI_RESULT_BUNDLE_PATH:-"N/A"}" >> "$summary_file"
    fi

    echo "✅ Test summary saved to test-summary.txt"
}

# Collect snapshots from various locations
echo "🗂️  Collecting snapshots from all known locations..."

# 1. CI resources (pre-staged snapshots)
collect_snapshots "$REPO_ROOT/VanessaGames/ci_scripts/resources/ClausySnapshots" "$TEMP_ARTIFACTS_DIR/ci-resources"

# 2. Generated snapshots in Games directory
collect_snapshots "$REPO_ROOT/VanessaGames/Games/ClausyTheCloud/Tests/SnapshotTests/__Snapshots__" "$TEMP_ARTIFACTS_DIR/game-snapshots"

# 3. Any snapshots in derived data or build directories
if [[ -n "$CI_DERIVED_DATA_PATH" ]]; then
    find "$CI_DERIVED_DATA_PATH" -type f \( -name "*.png" -o -name "*diff.png" \) 2>/dev/null | \
    while IFS= read -r file; do
        if [[ "$file" == *"__Snapshots__"* ]] || [[ "$file" == *"snapshot"* ]]; then
            rel_path="derived-data/${file##*/}"
            cp "$file" "$TEMP_ARTIFACTS_DIR/$rel_path" 2>/dev/null || true
            echo "  📦 Copied from derived data: ${file##*/}"
        fi
    done
fi

# 4. Look for any test failure artifacts
echo "🔍 Searching for test failure artifacts..."
find "$WORKSPACE_ROOT" -type f \( -name "*-failure-diff-*.png" -o -name "*-failed-*.png" \) 2>/dev/null | \
while IFS= read -r file; do
    if [[ -f "$file" ]]; then
        cp "$file" "$TEMP_ARTIFACTS_DIR/failures/" 2>/dev/null || {
            mkdir -p "$TEMP_ARTIFACTS_DIR/failures"
            cp "$file" "$TEMP_ARTIFACTS_DIR/failures/"
        }
        echo "  ❌ Copied failure artifact: ${file##*/}"
    fi
done

# Create additional information files
create_environment_info
create_test_summary

# Count collected files
SNAPSHOT_COUNT=$(find "$TEMP_ARTIFACTS_DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | wc -l | tr -d ' ')
TOTAL_FILE_COUNT=$(find "$TEMP_ARTIFACTS_DIR" -type f | wc -l | tr -d ' ')

echo "📊 Collection Summary:"
echo "  Snapshot files: $SNAPSHOT_COUNT"
echo "  Total files: $TOTAL_FILE_COUNT"

# Create the archive only if we have artifacts to archive
if [[ $TOTAL_FILE_COUNT -gt 0 ]]; then
    echo "📦 Creating snapshot artifacts archive..."

    # Create the archive
    cd "$WORKSPACE_ROOT"
    tar -czf "$SNAPSHOT_ARCHIVE_NAME" -C "$TEMP_ARTIFACTS_DIR" .

    if [[ -f "$SNAPSHOT_ARCHIVE_PATH" ]]; then
        ARCHIVE_SIZE=$(du -h "$SNAPSHOT_ARCHIVE_PATH" | cut -f1)
        echo "✅ Archive created successfully: $SNAPSHOT_ARCHIVE_NAME ($ARCHIVE_SIZE)"
        echo "📍 Archive location: $SNAPSHOT_ARCHIVE_PATH"

        # List the contents of the archive for verification
        echo "📋 Archive contents:"
        tar -tzf "$SNAPSHOT_ARCHIVE_PATH" | head -20
        if [[ $(tar -tzf "$SNAPSHOT_ARCHIVE_PATH" | wc -l) -gt 20 ]]; then
            echo "... and $(($(tar -tzf "$SNAPSHOT_ARCHIVE_PATH" | wc -l) - 20)) more files"
        fi
    else
        echo "❌ Failed to create archive"
        exit 1
    fi

    # Create a simple index file for easy download reference
    echo "snapshot-artifacts" > "$WORKSPACE_ROOT/artifacts-index.txt"
    echo "$SNAPSHOT_ARCHIVE_NAME" >> "$WORKSPACE_ROOT/artifacts-index.txt"
    echo "Size: $ARCHIVE_SIZE" >> "$WORKSPACE_ROOT/artifacts-index.txt"
    echo "Files: $TOTAL_FILE_COUNT ($SNAPSHOT_COUNT snapshots)" >> "$WORKSPACE_ROOT/artifacts-index.txt"

else
    echo "⚠️  No artifacts found to archive"

    # Create an empty marker file to indicate no artifacts were found
    echo "No snapshot artifacts were generated during this build." > "$WORKSPACE_ROOT/no-artifacts.txt"
    echo "This could indicate:" >> "$WORKSPACE_ROOT/no-artifacts.txt"
    echo "- All snapshot tests passed without generating new images" >> "$WORKSPACE_ROOT/no-artifacts.txt"
    echo "- Snapshot tests were disabled or skipped" >> "$WORKSPACE_ROOT/no-artifacts.txt"
    echo "- Test execution failed before snapshots could be generated" >> "$WORKSPACE_ROOT/no-artifacts.txt"
fi

# Cleanup temp directory
rm -rf "$TEMP_ARTIFACTS_DIR"

echo "🎉 Snapshot artifact collection completed!"
echo ""
echo "📥 To download and inspect snapshots:"
echo "1. Go to Xcode Cloud build details"
echo "2. Navigate to 'Artifacts' tab"
echo "3. Download '$SNAPSHOT_ARCHIVE_NAME'"
echo "4. Extract the archive to view all collected snapshots"
echo ""
