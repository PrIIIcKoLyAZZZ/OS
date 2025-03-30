#!/bin/bash
# Находим процесс с минимальным etimes (т.е. запущенный позже остальных)
latest_pid=$(ps -eo pid,etimes --no-headers | sort -k2 -n | head -n 1 | awk '{print $1}')
echo "PID последнего запущенного процесса: $latest_pid"
