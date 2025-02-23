#!/bin/bash
if [[ "$PWD/" == "$HOME"/* ]]; then
    echo "Домашний каталог: $HOME"
    exit 0
else
    echo "Ошибка: скрипт запущен не из домашнего каталога"
    exit 1
fi
