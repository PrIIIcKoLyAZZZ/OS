#!/bin/bash
# Скрипт: untrash.sh — восстановление из .trash рядом со скриптом

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TRASH_DIR="$SCRIPT_DIR/.trash"
LOG_FILE="$SCRIPT_DIR/trash.log"

if [ "$#" -ne 1 ]; then
  echo "Ошибка: укажите имя файла или каталога для восстановления." >&2
  exit 1
fi

RESTORE_NAME="$1"
FOUND=0
TMP_LOG="$(mktemp)"

if [ ! -f "$LOG_FILE" ]; then
  echo "Ошибка: лог не найден: $LOG_FILE" >&2
  exit 1
fi

while IFS= read -r LINE; do
  # формат: /абсолютный/путь -> ID (ACTION)
  ORIG="${LINE%% ->*}"
  RESTORE_ID="$(echo "${LINE#*-> }" | cut -d' ' -f1)"
  TYPE="$(echo "${LINE##*(}" | tr -d '()')"

  BASENAME="$(basename "$ORIG")"
  if [ "$BASENAME" = "$RESTORE_NAME" ]; then
    FOUND=1
    echo "Найдено: $ORIG  (ID=$RESTORE_ID, type=$TYPE)"
    printf "Восстановить? [y/n]: "
    read -r ANSWER < /dev/tty
    if [[ "$ANSWER" =~ ^[Yy]$ ]]; then
      DEST_DIR="$(dirname "$ORIG")"
      [ -d "$DEST_DIR" ] || mkdir -p -- "$DEST_DIR"
      SRC="$TRASH_DIR/$RESTORE_ID"
      DST="$ORIG"

      if [ "$TYPE" = "mv" ]; then
        mv -- "$SRC" "$DST"
      else
        ln -- "$SRC" "$DST" && rm -- "$SRC"
      fi
      echo "Восстановлено: $DST"
      # не пишем эту запись обратно в лог
      continue
    else
      echo "Пропущено восстановление: $RESTORE_NAME"
    fi
  fi
  # все прочие записи — сохраняем
  echo "$LINE" >> "$TMP_LOG"
done < "$LOG_FILE"

mv -- "$TMP_LOG" "$LOG_FILE"

if [ "$FOUND" -eq 0 ]; then
  echo "Не найдено записей для '$RESTORE_NAME'." >&2
  exit 1
fi
