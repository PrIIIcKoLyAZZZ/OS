#!/bin/bash
# Скрипт test_files.sh
# Назначение:
#   Создать тестовую среду с файлами и каталогами, имеющими нестандартные имена.
#   Это позволит проверить, что скрипты (rmtrash, untrash, backup, upback) корректно
#   обрабатывают файлы с пробелами, спецсимволами, переносами строк и т.п.

# Создание рабочего каталога "test_env"
mkdir -p "test_env" || { echo "Ошибка: не удалось создать каталог test_env."; exit 1; }
cd "test_env" || { echo "Ошибка: не удалось перейти в каталог test_env."; exit 1; }

# ======================
# Создание тестовых файлов
# ======================

# Файл с пробелами в имени
touch "file with spaces.txt" || echo "Ошибка при создании 'file with spaces.txt'"

# Файл, имя которого начинается с дефиса
touch -- "--leading-dash.txt" || echo "Ошибка при создании '--leading-dash.txt'"

# Файл со специальными символами: ?, #, &, |, ;, $
touch "special?file#&|;$.txt" || echo "Ошибка при создании 'special?file#&|;$.txt'"

# Файл с одинарными кавычками в имени
touch "'quoted file.txt'" || echo "Ошибка при создании ''quoted file.txt''"

# Файл с двойными кавычками в имени
touch "\"double quoted file.txt\"" || echo "Ошибка при создании '\"double quoted file.txt\"'"

# Файл с запятыми в имени
touch "file,with,commas.txt" || echo "Ошибка при создании 'file,with,commas.txt'"

# Файл с именем, содержащим символ новой строки
touch "$(echo -e 'file\nname.txt')" || echo "Ошибка при создании файла с новой строкой в имени"

# ======================
# Создание тестовых каталогов
# ======================

# Каталог с пробелами в имени
mkdir "directory with spaces" || echo "Ошибка при создании каталога 'directory with spaces'"

# Каталог, имя которого начинается с дефиса
mkdir -- "--dir-leading-dash" || echo "Ошибка при создании каталога '--dir-leading-dash'"

# Каталог со специальными символами
mkdir "special&directory#stuff" || echo "Ошибка при создании каталога 'special&directory#stuff'"

# ======================
# Создание вложенных каталогов
# ======================

# Вложенный каталог с пробелами в каждом уровне
mkdir -p "nested dir/inner folder" || echo "Ошибка при создании вложенных каталогов 'nested dir/inner folder'"

# Вложенный каталог в более сложной структуре
mkdir -p "complex-dir/sub-dir/another level" || echo "Ошибка при создании вложенных каталогов 'complex-dir/sub-dir/another level'"

# ======================
# Вывод результата
# ======================

echo "Тестовые файлы и каталоги созданы успешно в каталоге 'test_env'."
echo "Содержимое каталога 'test_env':"
ls -la

