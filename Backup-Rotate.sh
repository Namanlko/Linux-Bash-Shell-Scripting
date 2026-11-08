#!/usr/bin/env bash
# ============================================================
# Script Name : Backup-Rotate.sh
# Description : Creates a timestamped .tar.gz backup of a directory,
#               verifies it, writes a SHA-256 checksum and deletes
#               backups older than N days.
# Usage       : ./Backup-Rotate.sh <source_dir> <backup_dir> [retention_days]
# Example     : ./Backup-Rotate.sh /var/www /backups 7
# Cron (2 AM) : 0 2 * * * /opt/scripts/Backup-Rotate.sh /var/www /backups 7 >> /var/log/backup.log 2>&1
# Restore     : tar -xzf <archive> -C <target_dir>
# Author      : Naman Pandey
# ============================================================

set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: $0 <source_dir> <backup_dir> [retention_days]"
    exit 1
fi

SRC=$(realpath "$1")
DEST=$2
KEEP_DAYS=${3:-7}

[ -d "$SRC" ] || { echo "❌ Source directory not found: $SRC"; exit 1; }
[[ "$KEEP_DAYS" =~ ^[0-9]+$ ]] || { echo "❌ Retention must be a number of days"; exit 1; }

mkdir -p "$DEST"

NAME=$(basename "$SRC")
ARCHIVE="$DEST/${NAME}_$(date +%Y%m%d_%H%M%S).tar.gz"

# Remove a half-written archive if anything below fails
trap 'echo "❌ Backup failed, removing partial archive"; rm -f "$ARCHIVE" "$ARCHIVE.sha256"' ERR

echo "[$(date '+%F %T')] 📦 Backing up $SRC"
tar -czf "$ARCHIVE" -C "$(dirname "$SRC")" "$NAME"

echo "🔎 Verifying archive integrity..."
tar -tzf "$ARCHIVE" > /dev/null

(cd "$DEST" && sha256sum "$(basename "$ARCHIVE")" > "$(basename "$ARCHIVE").sha256")
trap - ERR

echo "✅ Created: $ARCHIVE ($(du -h "$ARCHIVE" | cut -f1))"
echo "🔑 Checksum: $ARCHIVE.sha256  (verify with: cd $DEST && sha256sum -c $(basename "$ARCHIVE").sha256)"

echo "🧹 Removing backups older than $KEEP_DAYS days..."
find "$DEST" -maxdepth 1 -type f -name "${NAME}_*.tar.gz*" -mtime +"$KEEP_DAYS" -print -delete

echo "📚 Backups kept: $(find "$DEST" -maxdepth 1 -type f -name "${NAME}_*.tar.gz" | wc -l)"
