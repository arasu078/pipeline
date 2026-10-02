# iOS Development Archive Pipeline

This repository includes a GitHub Actions workflow that runs whenever a commit is pushed to the `Dev` branch. It creates an unsigned `.xcarchive` on a self-hosted macOS runner and keeps the archive in a local folder on that Mac.

## Pipeline flow

1. A commit is pushed to `Dev`.
2. GitHub Actions sends the job to the registered self-hosted Mac.
3. The runner checks out the triggering commit.
4. `scripts/ci/archive.sh` runs `xcodebuild clean archive` using the `Pipeline` scheme and `Release` configuration.
5. The resulting archive is written to the configured local directory.
6. A copy is uploaded to the GitHub Actions run for 14 days.

On GitHub Actions, the default local output is a `PipelineArchives` directory beside the runner checkout, so normal checkout cleanup does not delete earlier archives. For local command-line runs, the default is `LocalArchives` inside this repository. You can choose an explicit persistent directory with `IOS_ARCHIVE_OUTPUT_DIR` as described below.

## One-time setup

### 1. Push the repository to GitHub

The project currently needs a GitHub remote before GitHub Actions can run. Commit the project and CI files, configure the remote, then push `main` and `Dev`.

Make sure `.github/workflows/ios-dev-archive.yml` exists on the `Dev` branch. Workflow changes that exist only on `main` will not run for a `Dev` push.

### 2. Prepare the build Mac

Install the Xcode version used by the project, open it once to finish component installation, and verify:

```bash
xcodebuild -version
xcode-select -p
```

If the required Xcode is not selected globally, set the repository variable `XCODE_DEVELOPER_DIR` to its Developer directory, for example:

```text
/Applications/Xcode-26.6.0.app/Contents/Developer
```

### 3. Register a self-hosted runner

In the GitHub repository, open **Settings → Actions → Runners → New self-hosted runner**, choose macOS, and run the commands GitHub provides on the build Mac.

Install the runner as a service so it remains available after logout or restart. Confirm that the runner shows as **Idle** and has the `self-hosted` and `macOS` labels. Keep the runner updated because the workflow uses the current Node 24-based GitHub actions.

### 4. Configure the archive directory

In **Settings → Secrets and variables → Actions → Variables**, add:

- `IOS_ARCHIVE_OUTPUT_DIR`: an absolute directory on the runner Mac, such as `/Users/runner/PipelineArchives`.
- `XCODE_DEVELOPER_DIR`: optional; use it when the required Xcode is not the active `xcode-select` installation.

The account running the self-hosted runner must have permission to create and write to the archive directory.

### 5. Test the workflow

First, open **Actions → iOS Development Archive → Run workflow** to test it manually. After that, every push to `Dev` triggers the same pipeline automatically.

For a local test without GitHub Actions:

```bash
ARCHIVE_OUTPUT_DIR="$PWD/LocalArchives" \
XCODE_DEVELOPER_DIR="/Applications/Xcode-26.6.0.app/Contents/Developer" \
bash scripts/ci/archive.sh
```

## Signed IPA export

The included pipeline deliberately creates an unsigned `.xcarchive`, which is suitable for build validation and preserving compiled output. Producing an installable or distributable `.ipa` additionally requires:

- an Apple distribution or development certificate installed in the runner keychain;
- matching provisioning profiles for the app and every extension target;
- an `ExportOptions.plist` matching the intended distribution method;
- a second `xcodebuild -exportArchive` step.

Keep signing certificates, passwords, and provisioning profiles in GitHub Actions secrets—never commit them to the repository.
