#!/bin/bash
# Файл, в который будет записан результат
output_file="processes_info.txt"
> "$output_file"

# Считаем количество процессов, запущенных текущим пользователем
proc_count=$(ps -u $(whoami) --no-headers | wc -l)
echo "$proc_count" > "$output_file"

# Выводим пары "PID:команда" для процессов текущего пользователя
ps -u $(whoami) -o pid,comm --no-headers | awk '{print $1 ":" $2}' >> "$output_file"
