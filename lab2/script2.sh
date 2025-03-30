#!/bin/bash
output_file="sbin_processes.txt"
> "$output_file"

# Выбираем процессы, команда которых начинается с /sbin/
ps -eo pid,cmd --no-headers | awk '$2 ~ "^/sbin/" {print $1}' > "$output_file"
