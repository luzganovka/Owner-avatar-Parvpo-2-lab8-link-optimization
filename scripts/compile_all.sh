#!/bin/bash

CXX="clang++"
CXXFLAGS="-Wall -Wextra -pedantic"
SRC_DIR="src"
BIN_DIR="bin"

# Уровни оптимизации компилятора
OPT_LEVELS=("O0" "O1" "O2" "O3" "Oz")

# Режимы LTO
LTO_MODES=("no-lto" "thin-lto" "full-lto")
LTO_FLAGS=("" "-flto=thin" "-flto")

mkdir -p "$BIN_DIR"

# Функция для сборки одного файла со всеми комбинациями оптимизаций
build_file() {
    local src_file="$1"
    local base_name=$(basename "$src_file" .cpp)

    echo "Building $base_name..."

    # Сборка без оптимизаций (по умолчанию)
    "$CXX" $CXXFLAGS "$src_file" -o "$BIN_DIR/$base_name"

    # Перебираем все комбинации оптимизаций
    for opt in "${OPT_LEVELS[@]}"; do
        for i in "${!LTO_MODES[@]}"; do
            local lto="${LTO_MODES[$i]}"
            local lto_flag="${LTO_FLAGS[$i]}"
            local output="$BIN_DIR/$base_name.$opt.$lto"

            echo "  Building $opt with $lto..."
            "$CXX" $CXXFLAGS -$opt $lto_flag "$src_file" -o "$output"
        done
    done
}

main() {
    # Находим все исходные файлы
    for src_file in "$SRC_DIR"/*.cpp; do
        if [ -f "$src_file" ]; then
            build_file "$src_file"
        fi
    done
}

main