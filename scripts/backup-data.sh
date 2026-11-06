#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="images/spark-debian/backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
TARGET_IMG="images/spark-debian/build/vm-candidate-20261024-01/data.ext4"
ARCHIVE="$BACKUP_DIR/data-backup-$TIMESTAMP.tar.gz"
ENCRYPTED_ARCHIVE="$ARCHIVE.gpg"

mkdir -p "$BACKUP_DIR"

if [ ! -f "$TARGET_IMG" ]; then
    echo "❌ Error: data.ext4 not found at $TARGET_IMG"
    exit 1
fi

echo "📦 Compressing data.ext4 into tarball..."
tar -czf "$ARCHIVE" -C "$(dirname "$TARGET_IMG")" "$(basename "$TARGET_IMG")"

echo "🔐 Encrypting backup archive with GPG..."
gpg --symmetric --cipher-algo AES256 --output "$ENCRYPTED_ARCHIVE" "$ARCHIVE"

# Cleanup unencrypted tarball
rm -f "$ARCHIVE"

# Generate SHA-256 checksum for audit integrity
shasum -a 256 "$ENCRYPTED_ARCHIVE" > "$ENCRYPTED_ARCHIVE.sha256"

echo "🧹 Rotating backups: removing archives older than 7 days..."
find "$BACKUP_DIR" -name "data-backup-*.tar.gz.gpg*" -mtime +7 -exec rm -f {} \;

echo "✅ Backup successfully created, encrypted, and rotated at: $ENCRYPTED_ARCHIVE"
