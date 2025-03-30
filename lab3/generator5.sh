#!/bin/bash
fifo="/tmp/myfifo"

# Проверяем наличие именованного канала и создаём, если отсутствует.
[ ! -p "$fifo" ] && mkfifo "$fifo"

echo "Введите команды (+, *, целое число или QUIT):"
while true; do
  read input
  # Отправляем ввод в именованный канал
  echo "$input" > "$fifo"
  # Если введено слово QUIT, завершаем работу генератора.
  if [ "$input" = "QUIT" ]; then
    exit 0
  fi
done
