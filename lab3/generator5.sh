#!/bin/bash

fifo="/tmp/myfifo"
[ -p "$fifo" ] || mkfifo "$fifo"

echo "Введите команды (+, *, целое число или QUIT):"
while true; do
  read input
  echo "$input" > "$fifo"
  [ "$input" = "QUIT" ] && break
done

