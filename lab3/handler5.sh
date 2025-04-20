#!/bin/bash

# Получаем путь к текущей папке скрипта
script_dir="$(cd "$(dirname "$0")" && pwd)"
log_file="$script_dir/fifo_output.log"

fifo="/tmp/myfifo"
[ -p "$fifo" ] || mkfifo "$fifo"

# Начальные значения
operation="add"
result=1

# Очистим лог
> "$log_file"

# Выводим начальное состояние
echo "[start] Начальное значение: $result" >> "$log_file"

# Читаем из FIFO
{
  while true; do
    if read line; then
      case "$line" in
        "+")
          operation="add"
          echo "[+] Переключение в режим сложения" >> "$log_file"
          ;;
        "*")
          operation="mul"
          echo "[*] Переключение в режим умножения" >> "$log_file"
          ;;
        "QUIT")
          echo "[!] Завершение по команде QUIT" >> "$log_file"
          rm -f "$fifo"
          exit 0
          ;;
        ''|*[!0-9-]*)
          echo "[X] Ошибка: недопустимый ввод: '$line'" >> "$log_file"
          rm -f "$fifo"
          exit 1
          ;;
        *)
          if [ "$operation" = "add" ]; then
            result=$((result + line))
            echo "[=] Добавляем $line → $result" >> "$log_file"
          else
            result=$((result * line))
            echo "[=] Умножаем на $line → $result" >> "$log_file"
          fi
          ;;
      esac
    fi
  done
} < "$fifo"

