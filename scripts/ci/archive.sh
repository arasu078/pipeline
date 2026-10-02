#!/usr/bin/env bash

set -euo pipefail

script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repository_root="$(cd "${script_directory}/../.." && pwd)"
cd "${repository_root}"

project_path="${PROJECT_PATH:-Pipeline.xcodeproj}"
scheme="${SCHEME:-Pipeline}"
configuration="${CONFIGURATION:-Release}"

if [[ -n "${XCODE_DEVELOPER_DIR:-}" ]]; then
    export DEVELOPER_DIR="${XCODE_DEVELOPER_DIR}"
fi

if [[ -z "${ARCHIVE_OUTPUT_DIR:-}" ]]; then
    if [[ "${GITHUB_ACTIONS:-false}" == "true" && -n "${GITHUB_WORKSPACE:-}" ]]; then
        workspace_parent="$(cd "${GITHUB_WORKSPACE}/.." && pwd)"
        archive_root="${workspace_parent}/PipelineArchives"
    else
        archive_root="${repository_root}/LocalArchives"
    fi
elif [[ "${ARCHIVE_OUTPUT_DIR}" = /* ]]; then
    archive_root="${ARCHIVE_OUTPUT_DIR}"
else
    archive_root="${repository_root}/${ARCHIVE_OUTPUT_DIR}"
fi

timestamp="$(date -u +%Y%m%d-%H%M%S)"
commit_sha="${GITHUB_SHA:-$(git rev-parse HEAD)}"
short_sha="${commit_sha:0:8}"
archive_name="${scheme}-${timestamp}-${short_sha}.xcarchive"
archive_path="${archive_root}/${archive_name}"
derived_data_path="${RUNNER_TEMP:-/tmp}/PipelineDerivedData-${short_sha}"

mkdir -p "${archive_root}"

echo "Archiving ${scheme} (${configuration})"
echo "Output: ${archive_path}"

xcodebuild clean archive \
    -project "${project_path}" \
    -scheme "${scheme}" \
    -configuration "${configuration}" \
    -destination "generic/platform=iOS" \
    -archivePath "${archive_path}" \
    -derivedDataPath "${derived_data_path}" \
    CODE_SIGNING_ALLOWED="${CODE_SIGNING_ALLOWED:-NO}"

test -d "${archive_path}"

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    echo "archive_path=${archive_path}" >> "${GITHUB_OUTPUT}"
fi

echo "Archive created successfully: ${archive_path}"
