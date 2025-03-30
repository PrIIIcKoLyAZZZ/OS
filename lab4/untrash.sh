#!/bin/bash
# Скрипт: untrash.sh
# Описание: Восстанавливает файл, удалённый скриптом rmtrash.sh, по имени (без пути).

if [ "$#" -ne 1 ]; then
  echo "Ошибка: Укажите имя файла для восстановления (без пути)." >&2
  exit 1
fi

restore_name="$1"
log_file="$HOME/trash.log"

if [ ! -f "$log_file" ]; then
  echo "Ошибка: Файл журнала '$log_file' не найден." >&2
  exit 1
fi

found=0
tmp_log=$(mktemp) || { echo "Ошибка: Не удалось создать временный файл." >&2; exit 1; }

while IFS= read -r line; do
  # Каждая строка формата: полный_путь -> имя_жёсткой_ссылки
  orig_path=$(echo "$line" | awk -F' -> ' '{print $1}')
  link_name=$(echo "$line" | awk -F' -> ' '{print $2}')
  orig_filename=$(basename "$orig_path")
  
  if [ "$orig_filename" = "$restore_name" ]; then
    found=1
    echo "Найден файл для восстановления: $orig_path"
    read -p "Восстановить этот файл? [y/n] " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      dest_dir=$(dirname "$orig_path")
      if [ ! -d "$dest_dir" ]; then
        echo "Директория '$dest_dir' не существует. Файл будет восстановлен в домашний каталог."
        dest_dir="$HOME"
      fi
      dest_path="$dest_dir/$orig_filename"
      # Если файл уже существует, запрашиваем новое имя
      while [ -e "$dest_path" ]; do
        echo "Файл '$dest_path' уже существует."
        read -p "Введите новое имя для восстанавливаемого файла: " new_name
        dest_path="$dest_dir/$new_name"
      done
      ln "$HOME/trash/$link_name" "$dest_path" 2>/dev/null
      if [ $? -eq 0 ]; then
        echo "Файл восстановлен по пути: $dest_path"
        rm "$HOME/trash/$link_name" 2>/dev/null
        # Не записываем эту строку во временный лог (удаляем запись)
        continue
      else
        echo "Ошибка: не удалось создать жёсткую ссылку для восстановления." >&2
      fi
    fi
  fi
  # Записываем строку во временный лог (если не удалена)
  echo "$line" >> "$tmp_log"
done < "$log_file"

mv "$tmp_log" "$log_file" 2>/dev/null || { echo "Ошибка: не удалось обновить '$log_file'." >&2; exit 1; }

if [ $found -eq 0 ]; then
  echo "Записи для файла '$restore_name' не найдены в '$log_file'."
fi

exit 0
