#!/bin/bash
output_file="process_info.txt"
> "$output_file"

# Перебираем все каталоги с числовыми именами в /proc
for pid in /proc/[0-9]*; do
    pid_num=$(basename "$pid")
    if [ -f "$pid/status" ] && [ -f "$pid/sched" ]; then
        # Извлекаем PPid
        ppid=$(grep "^PPid:" "$pid/status" | awk '{print $2}')
        # Извлекаем значения из /proc/[PID]/sched
        sum_exec_runtime=$(grep "se.sum_exec_runtime" "$pid/sched" | awk '{print $3}')
        nr_switches=$(grep "nr_switches" "$pid/sched" | awk '{print $3}')
        # Если данные получены и деление безопасно
        if [ -n "$sum_exec_runtime" ] && [ -n "$nr_switches" ] && [ "$nr_switches" -ne 0 ]; then
            art=$(echo "scale=6; $sum_exec_runtime / $nr_switches" | bc -l)
            echo "ProcessID=$pid_num : Parent_ProcessID=$ppid : Average_Running_Time=$art" >> "$output_file"
        fi
    fi
done

# Сортируем файл по значению PPID. Для этого извлекаем часть строки после "Parent_ProcessID="
awk -F"Parent_ProcessID=" '{split($2,a," "); print a[1] "\t" $0}' "$output_file" | sort -n | cut -f2- > tmp && mv tmp "$output_file"
