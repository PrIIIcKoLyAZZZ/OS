#!/bin/bash

# Перед запуском узнайте PID обработчика (его можно передать как аргумент или ввести вручную)
if [ -z "$1" ]; then
  echo "Укажите PID обработчика в качестве аргумента!"
  exit 1
fi

handler_pid=$1

echo "Генератор: отправка сигналов обработчику с PID $handler_pid."
while true; do
  read input
  case "$input" in
    "+")
      kill -USR1 $handler_pid
      echo "Отправлен сигнал USR1."
      ;;
    "*")
      kill -USR2 $handler_pid
      echo "Отправлен сигнал USR2."
      ;;
    *TERM*)
      kill -SIGTERM $handler_pid
      echo "Отправлен сигнал SIGTERM. Завершаю работу генератора."
      exit 0
      ;;
    *)
      # Игнорируем остальные строки
      echo "Игнорируется: $input"
      ;;
  esac
done
