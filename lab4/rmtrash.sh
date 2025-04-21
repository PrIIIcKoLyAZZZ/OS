#!/bin/bash

script_dir="$(dirname "$(realpath "$0")")"

# Проверка наличия аргумента
if [ $# -ne 1 ]; then
    echo "Ошибка: укажите имя файла для удаления."
    exit 1
fi

file="$1"
filepath="$(realpath "$file")"
filename="$(basename "$file")"

# Проверка, что файл существует и это обычный файл
if [ ! -f "$file" ]; then
    echo "Ошибка: файл '$file' не существует или не является обычным файлом."
    exit 1
fi

# Создание скрытого каталога ~/trash, если его нет
trash_dir="$script_dir/.trash"
[ ! -d "$trash_dir" ] && mkdir "$trash_dir"

# Создание уникального имени для жесткой ссылки
link_id=1
while [ -e "$trash_dir/$link_id" ]; do
    link_id=$((link_id + 1))
done

# Создание жесткой ссылки и удаление оригинального файла
ln "$file" "$trash_dir/$link_id" && rm "$file"

# Проверка успешности
if [ $? -eq 0 ]; then
    echo "Файл '$filename' перемещён в корзину как ссылка № $link_id."
else
    echo "Ошибка при создании ссылки или удалении файла."
    exit 1
fi

# Запись в лог
logfile="$script_dir/.trash.log"
echo "$filepath -> $link_id" >> "$logfile"
