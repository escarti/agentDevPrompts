#!/bin/bash
set -e

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: ./release.sh <version>"
  echo "Example: ./release.sh 1.3.4"
  exit 1
fi

echo "Releasing version $VERSION..."

# Update versions
sed -i '' "s/\"version\": \".*\"/\"version\": \"$VERSION\"/" plugin.json
sed -i '' "s/\"version\": \".*\"/\"version\": \"$VERSION\"/g" .claude-plugin/marketplace.json

# Check for changes
if [ -n "$(git status --porcelain)" ]; then
  git add .
  git commit -m "v$VERSION: Release

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
fi

# Push, tag, release
git push
git tag v$VERSION -m "v$VERSION"
git push origin v$VERSION

echo "✅ Released v$VERSION"
