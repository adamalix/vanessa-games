# Snapshot Testing Artifact Collection

This document describes the comprehensive snapshot testing artifact collection system implemented for Xcode Cloud.

## Overview

The snapshot artifact collection system helps you inspect and debug snapshot test results generated in the Xcode Cloud environment by automatically collecting, organizing, and archiving all snapshot-related files for download.

## How It Works

### 1. Environment Detection

The system automatically detects when running in CI environment using:

- `CI=TRUE` environment variable
- `CI_XCODE_CLOUD=TRUE` environment variable

### 2. Dynamic Recording Mode

In CI environments, snapshot tests are configured to record ALL snapshots (not just missing ones) to capture what's actually being generated. This helps debug CI-specific rendering differences.

### 3. Artifact Collection

The `ci_post_xcodebuild.sh` script collects snapshots from multiple locations:

- Pre-staged snapshots in `ci_scripts/resources/ClausySnapshots/`
- Generated snapshots in test directories
- Any failure diff images
- Snapshots in derived data directories

### 4. Archive Creation

All collected artifacts are organized and compressed into a timestamped archive:

- `snapshot-artifacts-YYYYMMDD-HHMMSS.tar.gz`

## Files and Structure

### CI Scripts

- `ci_pre_xcodebuild.sh` - Runs environment debugging
- `ci_post_xcodebuild.sh` - Collects and archives snapshot artifacts
- `debug_snapshot_environment.sh` - Provides detailed environment information

### Test Files

- `ContentViewSnapshotTests.swift` - Enhanced with CI environment detection and dynamic recording

### Generated Artifacts

When tests run in Xcode Cloud, the following files are created:

```
snapshot-artifacts-YYYYMMDD-HHMMSS.tar.gz
├── ci-resources/                    # Pre-staged snapshots
│   └── __Snapshots__/
├── game-snapshots/                  # Generated test snapshots
│   └── __Snapshots__/
├── derived-data/                    # Derived data snapshots
├── failures/                       # Test failure artifacts
├── environment-info.txt             # Environment details
└── test-summary.txt                 # Test execution summary
```

## How to Use

### 1. Download Artifacts

After an Xcode Cloud build completes:

1. Go to the Xcode Cloud build details page
2. Navigate to the **Artifacts** tab
3. Look for `snapshot-artifacts-YYYYMMDD-HHMMSS.tar.gz`
4. Download the archive

### 2. Extract and Inspect

```bash
# Extract the archive
tar -xzf snapshot-artifacts-YYYYMMDD-HHMMSS.tar.gz

# View environment information
cat environment-info.txt

# View test summary
cat test-summary.txt

# Inspect snapshots
open ci-resources/__Snapshots__/
open game-snapshots/__Snapshots__/
```

### 3. Compare with Local Snapshots

You can compare CI-generated snapshots with your local versions to identify differences:

```bash
# Compare specific snapshot
diff local-snapshot.png ci-resources/__Snapshots__/same-test.png

# Or use image comparison tools
open -a "Image View" local-snapshot.png ci-snapshot.png
```

## Troubleshooting

### No Artifacts Generated

If no artifacts are found, check:

- Tests are actually running (not skipped)
- Snapshot tests are enabled
- CI environment variables are set correctly
- File permissions allow writing to workspace

### Missing Snapshots

If expected snapshots are missing:

- Check the environment-info.txt for device/simulator details
- Verify tests are not failing before snapshot generation
- Check test-summary.txt for execution details

### Different Rendering

If CI snapshots look different from local:

- Compare environment details (iOS version, device model)
- Check for timing-related rendering issues
- Verify dependency injection is working correctly

## Environment Information

The debug script collects comprehensive environment information:

- Environment variables
- System information (macOS, Xcode versions)
- Available simulators
- Workspace and repository structure
- Derived data accessibility
- Test result bundle information
- System resources and permissions

## Advanced Usage

### Custom Snapshot Locations

To collect snapshots from additional locations, modify the `ci_post_xcodebuild.sh` script and add new `collect_snapshots` calls:

```bash
# Add custom snapshot location
collect_snapshots "/path/to/custom/snapshots" "$TEMP_ARTIFACTS_DIR/custom-snapshots"
```

### Selective Collection

To collect only specific types of snapshots, modify the file patterns in the collection functions.

### Extended Debugging

Run the debug script independently for detailed environment analysis:

```bash
./VanessaGames/ci_scripts/debug_snapshot_environment.sh
```

## Best Practices

1. **Always review artifacts** after CI failures to understand what's happening
2. **Compare with local snapshots** to identify environment-specific differences
3. **Use environment-info.txt** to understand the testing environment
4. **Check test-summary.txt** for test execution details
5. **Keep archives organized** by build number or date for historical comparison

## Integration with Existing Workflow

This system integrates seamlessly with your existing snapshot testing workflow:

- Local development continues to use `.missing` recording mode
- CI automatically switches to `.all` recording mode
- Existing snapshot files and directories are preserved
- No changes needed to test writing or execution

The artifact collection system provides complete visibility into what's happening during CI snapshot testing, making it much easier to debug and resolve CI-specific issues.
