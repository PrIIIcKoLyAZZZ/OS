#!/bin/bash
# untrash.sh — восстанавливает файл по имени

if [ "$#" -ne 1 ]; then
  echo "Ошибка: Укажите имя файла для восстановления." >&2
  exit 1
fi

restore_name="$1"
log_file="$HOME/trash.log"
trash_dir="$HOME/trash"
tmp_log=$(mktemp) || { echo "Ошибка: не удалось создать временный файл." >&2; exit 1; }

if [ ! -f "$log_file" ]; then
  echo "Ошибка: файл журнала '$log_file' не найден." >&2
  exit 1
fi

found=0

while IFS= read -r line; do
  orig_path="${line%% -> *}"
  link_name="${line##* -> }"
  base_name="$(basename "$orig_path")"

  if [ "$base_name" = "$restore_name" ]; then
    found=1
    echo "Найдено: $orig_path (в корзине: $link_name)"
    read -p "Восстановить этот файл? [y/n] " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      dest_dir="$(dirname "$orig_path")"
      [ -d "$dest_dir" ] || dest_dir="$HOME"
      dest_path="$dest_dir/$base_name"

      while [ -e "$dest_path" ]; do
        echo "Файл '$dest_path' уже существует."
        read -p "Введите новое имя для восстановления: " new_name
        dest_path="$dest_dir/$new_name"
      done

      ln "$trash_dir/$link_name" "$dest_path" && rm "$trash_dir/$link_name"
      echo "Восстановлено как: $dest_path"
      continue  # не записываем в новый лог
    fi
  fi
  echo "$line" >> "$tmp_log"
done < "$log_file"

mv "$tmp_log" "$log_file"

if [ $found -eq 0 ]; then
  echo "Файл '$restore_name' не найден в корзине."
fi
