#!/bin/bash
# 5) Извлечение строк с INFO
awk -F' ' '$2=="INFO"' /var/log/anaconda/syslog > info.log
