#!/bin/bash
# Скрипт: upback.sh
# Описание: Восстанавливает файлы из самого свежего каталога резервного копирования в $HOME/restore,
# исключая файлы с дополнительным расширением (версионные копии).

home_dir="$HOME"
restore_dir="$home_dir/restore"
backup_parent="$home_dir"

# Поиск каталога резервного копирования с самым свежим именем Backup-YYYY-MM-DD
active_backup=""
latest_date=""

for dir in "$backup_parent"/Backup-????-??-??; do
  [ -d "$dir" ] || continue
  base=$(basename "$dir")
  date_part=${base#Backup-}
  if date -d "$date_part" "+%Y-%m-%d" >/dev/null 2>&1; then
    if [ -z "$latest_date" ] || [ "$date_part" \> "$latest_date" ]; then
      latest_date="$date_part"
      active_backup="$dir"
    fi
  fi
done

if [ -z "$active_backup" ]; then
  echo "Ошибка: Не найден каталог резервного копирования." >&2
  exit 1
fi

# Создаем каталог восстановления, если его нет
if [ ! -d "$restore_dir" ]; then
  mkdir "$restore_dir" 2>/dev/null || { echo "Ошибка: Не удалось создать каталог '$restore_dir'." >&2; exit 1; }
fi

# Копирование файлов из активного каталога, исключая версионные (имена, заканчивающиеся на .YYYY-MM-DD)
shopt -s nullglob
copied_files=()
for file in "$active_backup"/*; do
  base=$(basename "$file")
  if [[ ! "$base" =~ \.[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    cp -p "$file" "$restore_dir/" 2>/dev/null
    if [ $? -eq 0 ]; then
      copied_files+=("$base")
    else
      echo "Ошибка: Не удалось скопировать '$file'." >&2
    fi
  fi
done

echo "Файлы из каталога резервного копирования '$(basename "$active_backup")' восстановлены в '$restore_dir'."
if [ ${#copied_files[@]} -gt 0 ]; then
  echo "Список восстановленных файлов:"
  for f in "${copied_files[@]}"; do
    echo "  $f"
  done
else
  echo "Нет файлов для восстановления."
fi

exit 0
