#!/bin/bash
# Скрипт: untrash.sh
# Описание: Восстанавливает файл, удалённый скриптом rmtrash.sh, по имени (без пути).

if [ "$#" -ne 1 ]; then
  echo "Ошибка: Укажите имя файла для восстановления (без пути)." >&2
  exit 1
fi

restore_name="$1"
script_dir="$(dirname "$(realpath "$0")")"
log_file="$script_dir/.trash.log"
trash_dir="$script_dir/.trash"
found=0
tmp_log=$(mktemp) || { echo "Ошибка: Не удалось создать временный файл." >&2; exit 1; }

if [ ! -f "$log_file" ]; then
  echo "Ошибка: Файл журнала '$log_file' не найден." >&2
  exit 1
fi

while IFS= read -r line; do
  orig_path=$(echo "$line" | awk -F' -> ' '{print $1}')
  link_name=$(echo "$line" | awk -F' -> ' '{print $2}')
  orig_filename=$(basename "$orig_path")

  if [ "$orig_filename" = "$restore_name" ]; then
    found=1
    echo "Найден файл для восстановления: $orig_path"
    echo -n "Восстановить этот файл? [y/n] "
    read answer < /dev/tty
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      dest_dir=$(dirname "$orig_path")
      if [ ! -d "$dest_dir" ]; then
        echo "Директория '$dest_dir' не существует. Файл будет восстановлен в домашний каталог."
        dest_dir="$HOME"
      fi

      if mv "$trash_dir/$link_name" "$dest_dir/$restore_name"; then
        echo "Файл успешно восстановлен в: $dest_dir/$restore_name"
        continue  # не добавлять эту строку обратно в лог
      else
        echo "Ошибка при восстановлении файла." >&2
        echo "$line" >> "$tmp_log"
      fi
    else
      echo "$line" >> "$tmp_log"  # оставляем строку, если пользователь отказался
    fi
  else
    echo "$line" >> "$tmp_log"
  fi
done < "$log_file"

if [ "$found" -eq 0 ]; then
  echo "Файл с именем '$restore_name' не найден в журнале." >&2
  rm "$tmp_log"
  exit 1
fi

mv "$tmp_log" "$log_file"
