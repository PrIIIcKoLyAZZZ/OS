#!/bin/bash
# 3) Текстовое меню
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
