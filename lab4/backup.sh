#!/bin/bash
# backup.sh — создаёт или обновляет резервную копию файлов из ~/source
# в каталог ~/Backup-YYYY-MM-DD. Все действия логируются в ~/backup-report.

set -euo pipefail

home="$HOME"
src="$home/source"
report="$home/backup-report"
now=$(date '+%Y-%m-%d')
now_sec=$(date -d "$now" +%s)
seven_days=$((7 * 24 * 60 * 60))

if [ ! -d "$src" ]; then
  echo "Ошибка: каталог $src не существует." >&2
  exit 1
fi

# Найдём актуальный бэкап, не старше 7 дней
backup_dir=""
for dir in "$home"/Backup-*; do
  [ -d "$dir" ] || continue
  date_part="${dir##*/Backup-}"
  if ! date -d "$date_part" &>/dev/null; then continue; fi
  dir_sec=$(date -d "$date_part" +%s)
  age=$(( now_sec - dir_sec ))
  if [ "$age" -le "$seven_days" ]; then
    if [ -z "$backup_dir" ] || [[ "$date_part" > "${backup_dir##*/Backup-}" ]]; then
      backup_dir="$dir"
    fi
  fi
done

# Если нет актуального — создаём новый
if [ -z "$backup_dir" ]; then
  backup_dir="$home/Backup-$now"
  mkdir "$backup_dir"
  echo "Создан новый каталог резервной копии: $backup_dir" >> "$report"
fi

echo "Резервное копирование в $backup_dir от $now" >> "$report"

# Копируем или обновляем файлы
for file in "$src"/*; do
  base=$(basename "$file")
  dest="$backup_dir/$base"

  if [ ! -e "$dest" ]; then
    cp "$file" "$dest"
    echo "Скопирован новый файл: $base" >> "$report"
  else
    # если файл изменён — переименуем старый
    if ! cmp -s "$file" "$dest"; then
      mv "$dest" "$dest.$now"
      cp "$file" "$dest"
      echo "Обновлён файл: $base, старая версия сохранена как $base.$now" >> "$report"
    fi
  fi
done
