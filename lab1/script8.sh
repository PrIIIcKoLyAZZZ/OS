#!/bin/bash
# 8) Вывести список пользователей с UID
awk -F: '{print $1, $3}' /etc/passwd | sort -nk2
