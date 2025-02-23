#!/bin/bash

# i) Вывести максимальное из трех чисел
if [ "$1" ] && [ "$2" ] && [ "$3" ]; then
    echo "Максимальное число: $(echo -e "$1\n$2\n$3" | sort -nr | head -n1)"
fi

# ii) Считывание строк до ввода 'q'
echo "Введите строки, для завершения введите 'q':"
result=""
while read line; do
    [ "$line" = "q" ] && break
    result+="$line "
done
echo "Результат: $result"

# iii) Текстовое меню
while true; do
    echo "Меню:\n1. nano\n2. vi\n3. links\n4. Выход"
    read choice
    case $choice in
        1) nano ;;
        2) vi ;;
        3) links ;;
        4) exit 0 ;;
        *) echo "Неверный ввод" ;;
    esac
done

# iv) Проверка директории запуска
if [ "$PWD" = "$HOME" ]; then
    echo "Домашний каталог: $HOME"
    exit 0
else
    echo "Ошибка: скрипт запущен не из домашнего каталога"
    exit 1
fi

# v) Извлечение строк с INFO
awk -F' ' '$2=="INFO"' /var/log/anaconda/syslog > info.log

# vi) Создание full.log с предупреждениями и инфо-сообщениями
grep -E "(WW|II)" /var/log/anaconda/X.log | \
    sed -E 's/^WW/Warning:/; s/^II/Information:/' | \
    sort -r > full.log
cat full.log

# vii) Извлечение email-адресов
grep -Eroh "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" /etc | paste -sd, - > emails.lst

# viii) Вывести список пользователей с UID
awk -F: '{print $1, $3}' /etc/passwd | sort -nk2

# ix) Подсчет строк в log-файлах
find /var/log/ -type f -name "*.log" -exec wc -l {} + | awk '{sum+=$1} END {print "Общее количество строк:", sum}'

# x) Три самых частых слова из man bash длиной > 4
man bash | tr -c '[:alnum:]' '[\n*]' | awk 'length($0)>=4' | sort | uniq -c | sort -nr | head -3
