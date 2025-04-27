#!/bin/bash
# Скрипт: rmtrash.sh — «безопасное» удаление файлов и папок в .trash рядом со скриптом

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TRASH_DIR="$SCRIPT_DIR/.trash"
LOG_FILE="$SCRIPT_DIR/trash.log"

# Проверка аргумента
if [ "$#" -ne 1 ]; then
  echo "Ошибка: укажите путь к файлу или каталогу для удаления." >&2
  exit 1
fi

TARGET="$1"
ABS_PATH="$(realpath "$TARGET")"
NAME="$(basename "$TARGET")"

if [ ! -e "$TARGET" ]; then
  echo "Ошибка: '$TARGET' не найден." >&2
  exit 1
fi

# Создать корзину
mkdir -p -- "$TRASH_DIR"

# Найти уникальный идентификатор
i=1
while [ -e "$TRASH_DIR/$i" ]; do
  i=$((i+1))
done

# Если это каталог — переместить
if [ -d "$TARGET" ]; then
  mv -- "$TARGET" "$TRASH_DIR/$i"
  ACTION="mv"
else
  # файл — создать жёсткую ссылку и удалить
  ln -- "$TARGET" "$TRASH_DIR/$i"
  rm -- "$TARGET"
  ACTION="ln"
fi

# Запись в лог
printf "%s -> %s (%s)\n" "$ABS_PATH" "$i" "$ACTION" >> "$LOG_FILE"
echo "Перемещено в корзину [$i]: $TARGET"
