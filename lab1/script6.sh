#!/bin/bash
# 6) Создание full.log с предупреждениями и инфо-сообщениями
grep -E "(WW|II)" /var/log/anaconda/X.log | \
    sed -E 's/^WW/Warning:/; s/^II/Information:/' | \
    sort -r > full.log
cat full.log
