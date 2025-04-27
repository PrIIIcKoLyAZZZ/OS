#!/bin/bash
# backup.sh — создаёт или обновляет резервную копию всей текущей директории (кроме .sh)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPORT_FILE="$SCRIPT_DIR/backup-report"
CURRENT_DATE=$(date "+%Y-%m-%d")
CURRENT_SEC=$(date -d "$CURRENT_DATE" +%s)
SEVEN_DAYS=$((7*24*3600))

# Ищем активный каталог бэкапа ≤7 дней
active=""
for d in "$SCRIPT_DIR"/Backup-????-??-??; do
  [ -d "$d" ] || continue
  dt="${d##*/Backup-}"
  if date -d "$dt" >/dev/null 2>&1; then
    age=$(( CURRENT_SEC - $(date -d "$dt" +%s) ))
    if [ $age -lt $SEVEN_DAYS ]; then
      active="$d"
    fi
  fi
done

# Если нет — создаём новый
if [ -z "$active" ]; then
  active="$SCRIPT_DIR/Backup-$CURRENT_DATE"
  mkdir -- "$active"
  echo "[$CURRENT_DATE] Новый бэкап: $(basename "$active")" >> "$REPORT_FILE"
else
  echo "[$CURRENT_DATE] Обновление бэкапа: $(basename "$active")" >> "$REPORT_FILE"
fi

# Перебираем всё в SCRIPT_DIR, кроме самих скриптов и бэкап-папок
shopt -s dotglob nullglob
for item in "$SCRIPT_DIR"/* "$SCRIPT_DIR"/.*; do
  [ "$item" = "$SCRIPT_DIR/." ] && continue
  [ "$item" = "$SCRIPT_DIR/.." ] && continue
  base="$(basename "$item")"
  # пропускаем скрипты и служебные папки
  case "$base" in
    backup.sh|upback.sh|rmtrash.sh|untrash.sh|test_files.sh) continue ;;
    Backup-????-??-??|restore|.trash|*.log|backup-report) continue ;;
  esac

  dest="$active/$base"

  if [ -d "$item" ]; then
    # это каталог
    if [ ! -d "$dest" ]; then
      cp -pr -- "$item" "$dest"
      echo "Добавлен каталог: $base" >> "$REPORT_FILE"
    else
      # уже есть — копируем внутрь изменения
      cp -pr -- "$item"/. "$dest"/
      echo "Обновлён каталог: $base" >> "$REPORT_FILE"
    fi

  elif [ -f "$item" ]; then
    # файл
    if [ ! -e "$dest" ]; then
      cp -p -- "$item" "$dest"
      echo "Добавлен файл: $base" >> "$REPORT_FILE"
    else
      if ! cmp -s -- "$item" "$dest"; then
        mv -- "$dest" "$dest.$CURRENT_DATE"
        cp -p -- "$item" "$dest"
        echo "Обновлён файл: $base (предыдущая версия → $base.$CURRENT_DATE)" >> "$REPORT_FILE"
      fi
    fi
  fi
done

echo "Резервное копирование завершено." >> "$REPORT_FILE"
