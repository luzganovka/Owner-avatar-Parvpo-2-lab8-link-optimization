#!/bin/bash

# Скрипт для последовательного запуска всех исполняемых файлов из папки bin

# Проверяем, что папка bin существует
BIN_DIR="bin"
if [ ! -d "$BIN_DIR" ]; then
    echo "Ошибка: папка $BIN_DIR не найдена!"
    exit 1
fi

# Получаем список файлов в алфавитном порядке
BIN_FILES=$(find "$BIN_DIR" -type f -executable | sort)

# Проверяем, есть ли файлы для запуска
if [ -z "$BIN_FILES" ]; then
    echo "Нет исполняемых файлов в $BIN_DIR"
    exit 0
fi

echo "Найдены следующие исполняемые файлы:"
echo "$BIN_FILES" | sed 's|.*/||'
echo "----------------------------------"

# Запускаем каждый файл с переданными аргументами
for binary in $BIN_FILES; do
    filename=$(basename "$binary")
    echo "running $filename with parameters: $@"
    echo "----------------------------------"
    
    "$binary" "$@"
    exit_code=$?
    
    echo "----------------------------------"
    echo "Файл $filename завершился с кодом $exit_code"
done

echo "Все программы выполнены"