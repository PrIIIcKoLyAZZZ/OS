#!/bin/bash
# Задание 1. Файл: script1.sh

# Пытаемся создать каталог ~/test.
# Если mkdir успешен, выполняется цепочка команд после &&:
mkdir "$HOME/test" 2>/dev/null && \
  echo "catalog test was created successfully" >> "$HOME/report" && \
  touch "$HOME/test/$(date '+%Y-%m-%d_%H-%M-%S')"

# Независимо от результата, пингуем хост.
# Если ping завершается с ошибкой, дописываем сообщение в ~/report.
ping -c 1 www.net_nikogo.ru > /dev/null 2>&1 || \
  echo "$(date '+%Y-%m-%d %H:%M:%S') Error: Host www.net_nikogo.ru is unreachable" >> "$HOME/report"
