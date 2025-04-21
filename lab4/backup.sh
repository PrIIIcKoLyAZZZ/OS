#!/bin/bash
# Скрипт: backup.sh
# Описание: Создаёт или обновляет резервную копию файлов из $HOME/source в каталоге резервного копирования.
# Отчёт записывается в $HOME/backup-report.

set -euo pipefail

home_dir="$HOME"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$script_dir"
report_file="$script_dir/backup-report"
current_date=$(date "+%Y-%m-%d")
current_sec=$(date -d "$current_date" +%s)
seven_days=$((7 * 24 * 3600))

error_exit() {
  echo "Ошибка: $1" >&2
  exit 1
}

if [ ! -d "$source_dir" ]; then
  error_exit "Каталог источника '$source_dir' не найден."
fi

# Поиск активного каталога резервного копирования (Backup-YYYY-MM-DD, созданного не ранее 7 дней назад)
active_backup=""
for dir in "$home_dir"/Backup-????-??-??; do
  [ -d "$dir" ] || continue
  base=$(basename "$dir")
  backup_date=${base#Backup-}
  if ! date -d "$backup_date" "+%Y-%m-%d" >/dev/null 2>&1; then
    continue
  fi
  backup_sec=$(date -d "$backup_date" +%s)
  diff=$(( current_sec - backup_sec ))
  if [ $diff -lt $seven_days ]; then
    if [ -z "$active_backup" ] || [ "$backup_date" \> "${active_backup#Backup-}" ]; then
      active_backup="$dir"
    fi
  fi
done

new_backup_created=0
if [ -z "$active_backup" ]; then
  active_backup="$home_dir/Backup-$current_date"
  mkdir "$active_backup" 2>/dev/null || error_exit "Не удалось создать каталог '$active_backup'."
  new_backup_created=1
  echo "Создан новый каталог резервного копирования: $(basename "$active_backup"), Дата: $current_date" >> "$report_file"
fi

# Массивы для отчёта
added_new_files=()
updated_files=()

shopt -s nullglob
for file in "$source_dir"/*; do
  if [ -f "$file" ]; then
    base=$(basename "$file")
    dest_file="$active_backup/$base"
    if [ ! -e "$dest_file" ]; then
      cp -p "$file" "$dest_file" 2>/dev/null || echo "Ошибка копирования файла '$file'" >&2
      added_new_files+=("$base")
    else
      src_size=$(stat -c%s "$file")
      dest_size=$(stat -c%s "$dest_file")
      if [ "$src_size" -ne "$dest_size" ]; then
        versioned_name="$dest_file.$current_date"
        mv "$dest_file" "$versioned_name" 2>/dev/null || { echo "Ошибка переименования файла '$dest_file'" >&2; continue; }
        cp -p "$file" "$dest_file" 2>/dev/null || { echo "Ошибка копирования файла '$file'" >&2; continue; }
        updated_files+=("$base -> $(basename "$versioned_name")")
      fi
    fi
  fi
done

# Формирование отчёта
if [ $new_backup_created -eq 1 ]; then
  {
    echo "Новый каталог резервного копирования: $(basename "$active_backup"), создан: $current_date"
    if [ ${#added_new_files[@]} -gt 0 ]; then
      echo "Скопированы файлы:"
      for f in "${added_new_files[@]}"; do
        echo "  $f"
      done
    else
      echo "Нет новых файлов для копирования."
    fi
    echo "-----------------------------------"
  } >> "$report_file"
else
  {
    echo "Внесены изменения в активный каталог резервного копирования: $(basename "$active_backup"), дата изменений: $current_date"
    if [ ${#added_new_files[@]} -gt 0 ]; then
      echo "Добавлены новые файлы:"
      for f in "${added_new_files[@]}"; do
        echo "  $f"
      done
    fi
    if [ ${#updated_files[@]} -gt 0 ]; then
      echo "Обновлены файлы (созданы версионные копии):"
      for f in "${updated_files[@]}"; do
        echo "  $f"
      done
    fi
    echo "-----------------------------------"
  } >> "$report_file"
fi

echo "Операция резервного копирования завершена."
exit 0
