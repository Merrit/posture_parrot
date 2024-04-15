#!/bin/bash

# Create a new release on GitHub and upload artifacts


# Check number of arguments
if [ "$#" -ne 4 ]; then
  echo "Usage: $0 TOKEN REPO REF ARTIFACTS_PATH"
  exit 1
fi


# Variables
## $1: GitHub token
TOKEN=$1
## $2: GitHub repository, e.g. "owner/repo"
REPO=$2
## $3: Git reference, e.g. "main" or "v1.0.0"
REF=$3
## $4: Path to artifacts
ARTIFACTS_PATH=$4


# Create a new release
response=$(curl -s -X POST -H "Authorization: token $TOKEN" -d "{\
  \"tag_name\": \"latest\",\
  \"target_commitish\": \"$REF\",\
  \"name\": \"Development Build\",\
  \"body\": \"\",\
  \"draft\": false,\
  \"prerelease\": true\
}" "https://api.github.com/repos/$REPO/releases")

# Check for errors
if echo "$response" | grep -q "\"id\":"; then
  release_id=$(echo "$response" | jq -r '.id')
else
  echo "Failed to create release: $response"
  exit 1
fi


# Upload the artifacts
find "$ARTIFACTS_PATH" -type f | while IFS= read -r file; do
  echo "Uploading $file"
  upload_response=$(curl -s -X POST -H "Authorization: token $TOKEN" -H "Content-Type: application/octet-stream" --data-binary "@$file" "https://uploads.github.com/repos/$REPO/releases/$release_id/assets?name=$(basename "$file")")
  
  # Check for errors
  if ! echo "$upload_response" | grep -q "\"id\":"; then
    echo "Failed to upload artifact: $upload_response"
    exit 1
  fi
done
