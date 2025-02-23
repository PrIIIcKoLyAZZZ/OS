#!/bin/bash
# 9) Подсчет строк в log-файлах
find /var/log/ -type f -name "*.log" -exec wc -l {} + | awk '{sum+=$1} END {print "Общее количество строк:", sum}'
