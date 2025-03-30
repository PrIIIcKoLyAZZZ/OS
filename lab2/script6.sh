#!/bin/bash
max_mem=0
max_pid=0
max_cmd=""

for pid in /proc/[0-9]*; do
    pid_num=$(basename "$pid")
    if [ -f "$pid/status" ]; then
        # Извлекаем значение VmRSS (в килобайтах)
        mem=$(grep "^VmRSS:" "$pid/status" | awk '{print $2}')
        if [ -n "$mem" ]; then
            if [ "$mem" -gt "$max_mem" ]; then
                max_mem=$mem
                max_pid=$pid_num
                # Получаем командную строку процесса
                if [ -f "$pid/cmdline" ]; then
                    cmd=$(tr "\0" " " < "$pid/cmdline")
                else
                    cmd="N/A"
                fi
                max_cmd=$cmd
            fi
        fi
    fi
done

echo "Процесс с наибольшим использованием памяти:"
echo "PID=$max_pid, Memory=${max_mem}kB, Command: $max_cmd"
echo ""
echo "Вывод команды top (первая страница):"
top -b -n 1 | head -n 20
