#!/bin/bash
# 2) Считывание строк до ввода 'q'
echo "Введите строки, для завершения введите 'q':"
result=""
while read line; do
    [ "$line" = "q" ] && break
    result+="$line "
done
echo "Результат: $resul"
