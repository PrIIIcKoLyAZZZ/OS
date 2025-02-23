#!/bin/bash
# 10) Три самых частых слова из man bash длиной > 4
man bash | tr -c '[:alnum:]' '[\n*]' | awk 'length($0)>=4' | sort | uniq -c | sort -nr | head -3
