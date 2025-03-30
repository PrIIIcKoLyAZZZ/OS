#!/bin/bash
declare -A initial_read

# Фиксируем начальные значения read_bytes для процессов, у которых есть /proc/[PID]/io
for pid in /proc/[0-9]*; do
    pid_num=$(basename "$pid")
    if [ -f "$pid/io" ]; then
        read_bytes=$(grep "^read_bytes:" "$pid/io" | awk '{print $2}')
        if [ -n "$read_bytes" ]; then
            initial_read[$pid_num]=$read_bytes
        fi
    fi
done

echo "Замер значений read_bytes выполнен. Ждем 60 секунд..."
sleep 60

declare -A diff_read

# Вычисляем разницу для процессов, которые существуют спустя 60 секунд
for pid in /proc/[0-9]*; do
    pid_num=$(basename "$pid")
    if [ -n "${initial_read[$pid_num]}" ] && [ -f "$pid/io" ]; then
        read_bytes=$(grep "^read_bytes:" "$pid/io" | awk '{print $2}')
        if [ -n "$read_bytes" ]; then
            diff=$(( read_bytes - initial_read[$pid_num] ))
            diff_read[$pid_num]=$diff
        fi
    fi
done

# Сохраняем результаты во временный файл для сортировки
temp_file=$(mktemp)
for pid in "${!diff_read[@]}"; do
    echo "$pid ${diff_read[$pid]}" >> "$temp_file"
done

# Сортируем по убыванию прироста и выбираем топ-3
top3=$(sort -k2 -n -r "$temp_file" | head -n 3)

echo "Три процесса с максимальным приростом прочитанных байт за 1 минуту:"
while read -r pid bytes; do
    # Получаем командную строку процесса
    if [ -f "/proc/$pid/cmdline" ]; then
         cmd=$(tr "\0" " " < "/proc/$pid/cmdline")
    else
         cmd="N/A"
    fi
    echo "$pid : $cmd : $bytes"
done <<< "$top3"

rm "$temp_file"
