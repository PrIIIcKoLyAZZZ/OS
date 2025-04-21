#!/bin/bash
# upback.sh — восстанавливает содержимое из последнего каталога Backup-*

set -euo pipefail

home="$HOME"
latest_backup=""
latest_date=""

for dir in "$home"/Backup-*; do
  [ -d "$dir" ] || continue
  date_part="${dir##*/Backup-}"
  if ! date -d "$date_part" &>/dev/null; then continue; fi
  if [ -z "$latest_date" ] || [[ "$date_part" > "$latest_date" ]]; then
    latest_date="$date_part"
    latest_backup="$dir"
  fi
done

if [ -z "$latest_backup" ]; then
  echo "Ошибка: не найдено резервных копий." >&2
  exit 1
fi

restore_dir="$home/restore"
mkdir -p "$restore_dir"

cp -a "$latest_backup"/. "$restore_dir"/

echo "Резервная копия из $latest_backup восстановлена в $restore_dir"
