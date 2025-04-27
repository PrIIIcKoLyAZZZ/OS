#!/bin/bash
# upback.sh — восстанавливает каталоги и файлы на их исходные места из последнего бэкапа

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Находим самый свежий бэкап
latest=""
latest_dt=""
for d in "$SCRIPT_DIR"/Backup-????-??-??; do
  [ -d "$d" ] || continue
  dt="${d##*/Backup-}"
  if date -d "$dt" >/dev/null 2>&1; then
    if [[ -z "$latest_dt" || "$dt" > "$latest_dt" ]]; then
      latest_dt="$dt"
      latest="$d"
    fi
  fi
done

if [ -z "$latest" ]; then
  echo "Ошибка: не найден ни один бэкап" >&2
  exit 1
fi

echo "Восстановление из: $(basename "$latest")"

shopt -s dotglob nullglob
for entry in "$latest"/* "$latest"/.*; do
  [ "$entry" = "$latest/." ] && continue
  [ "$entry" = "$latest/.." ] && continue
  name="$(basename "$entry")"
  # пропускаем файлы-версии
  if [[ "$name" =~ \.[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    continue
  fi

  src="$entry"
  dst="$SCRIPT_DIR/$name"

  if [ -d "$src" ]; then
    mkdir -p -- "$dst"
    cp -pr -- "$src"/. "$dst"/
    echo "Каталог восстановлен: $name"
  else
    mkdir -p -- "$(dirname "$dst")"
    cp -p -- "$src" "$dst"
    echo "Файл восстановлен: $name"
  fi
done

echo "Восстановление завершено."
