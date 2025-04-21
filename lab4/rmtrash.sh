#!/bin/bash
# rmtrash.sh — удаляет файл, создавая жёсткую ссылку в $HOME/trash

if [ "$#" -ne 1 ]; then
  echo "Ошибка: Укажите имя файла для удаления." >&2
  exit 1
fi

target_file="$1"
trash_dir="$HOME/trash"
log_file="$HOME/trash.log"

if [ ! -f "$target_file" ]; then
  echo "Ошибка: файл '$target_file' не существует или не является обычным файлом." >&2
  exit 1
fi

mkdir -p "$trash_dir" || { echo "Ошибка: не удалось создать каталог trash." >&2; exit 1; }

# Найдём уникальное имя
i=1
while [ -e "$trash_dir/$i" ]; do
  i=$((i + 1))
done

ln "$target_file" "$trash_dir/$i" || { echo "Ошибка: не удалось создать жёсткую ссылку." >&2; exit 1; }
rm -- "$target_file" || { echo "Ошибка: не удалось удалить оригинальный файл." >&2; exit 1; }

# Добавим в лог
printf "%s -> %s\n" "$(realpath "$target_file")" "$i" >> "$log_file"
echo "Файл перемещён в корзину как: $i"
