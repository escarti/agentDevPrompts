#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: ./scripts/release.sh <version>"
  echo "Example: ./scripts/release.sh 1.3.4"
  exit 1
fi

echo "Releasing version $VERSION..."

# Update versions
sed -i '' "s/\"version\": \".*\"/\"version\": \"$VERSION\"/" "$ROOT_DIR/.claude-plugin/plugin.json"
sed -i '' "s/\"version\": \".*\"/\"version\": \"$VERSION\"/g" "$ROOT_DIR/.claude-plugin/marketplace.json"

# Check for changes
if [ -n "$(git -C "$ROOT_DIR" status --porcelain)" ]; then
  git -C "$ROOT_DIR" add .
  git -C "$ROOT_DIR" commit -m "v$VERSION: Release

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
fi

# Push, tag, release
git -C "$ROOT_DIR" push
git -C "$ROOT_DIR" tag v$VERSION -m "v$VERSION"
git -C "$ROOT_DIR" push origin v$VERSION

echo "✅ Released v$VERSION"
