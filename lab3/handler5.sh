#!/bin/bash
# Инициализация: режим – сложение, вычисляемая переменная равна 1.
mode="add"
result=1

# Чтение из именованного канала /tmp/myfifo
while true; do
  if read line < /tmp/myfifo; then
    case "$line" in
      "+")
        mode="add"
        echo "Режим переключён на сложение."
        ;;
      "*")
        mode="mul"
        echo "Режим переключён на умножение."
        ;;
      QUIT)
        echo "Получено сообщение QUIT. Планируется остановка."
        exit 0
        ;;
      ''|*[!0-9-]*)
        echo "Ошибка входных данных: '$line'"
        exit 1
        ;;
      *)
        # Если строка содержит целое число
        num="$line"
        if [ "$mode" = "add" ]; then
          result=$((result + num))
        else
          result=$((result * num))
        fi
        echo "Новый результат: $result"
        ;;
    esac
  fi
done
