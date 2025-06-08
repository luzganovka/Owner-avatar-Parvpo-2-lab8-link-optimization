#!/bin/bash

CXX="clang++"
CXXFLAGS="-Wall -Wextra -pedantic"
SRC_DIR="src"
BIN_DIR="bin"
RESULTS_FILE="compile_times.csv"
ITERATIONS=10
TARGET_NAME="program"  # Базовое имя исполняемого файла

# Уровни оптимизации
OPT_LEVELS=("O0" "O1" "O2" "O3" "Os" "Oz")

# Режимы LTO
LTO_MODES=("no-lto" "thin-lto" "full-lto")
LTO_FLAGS=("" "-flto=thin" "-flto")

mkdir -p "$BIN_DIR"

# Заголовок CSV
echo "Optimization Level,LTO Mode,Min Time (s),Avg Time (s),Max Time (s),Binary Size (bytes)" > "$RESULTS_FILE"

# Функция для замера времени
measure_compile() {
    local cmd="$1"
    local total=0 min_time=9999 max_time=0

    for ((i=1; i<=ITERATIONS; i++)); do
        # Чистим кеш компилятора
        if command -v ccache &> /dev/null; then
            ccache -C >/dev/null
        fi

        # Замер времени
        local time_output
        time_output=$( { time -p $cmd >/dev/null 2>&1; } 2>&1 )
        local real_time=$(echo "$time_output" | grep real | awk '{print $2}')

        # Обновляем статистику
        total=$(echo "$total + $real_time" | bc)
        if (( $(echo "$real_time < $min_time" | bc -l) )); then
            min_time=$real_time
        fi
        if (( $(echo "$real_time > $max_time" | bc -l) )); then
            max_time=$real_time
        fi
    done

    local avg_time=$(echo "scale=4; $total / $ITERATIONS" | bc)
    echo "$min_time $avg_time $max_time"
}

# Компиляция всех файлов вместе
compile_all() {
    local opt="$1"
    local lto="$2"
    local lto_flag="$3"
    local output="$BIN_DIR/$TARGET_NAME.$opt.$lto"

    echo -n "Building with -$opt $lto (${ITERATIONS}x)..."

    # Удаляем старый бинарник
    rm -f "$output"

    # Замер времени
    local cmd="$CXX $CXXFLAGS -$opt $lto_flag ${CPP_FILES[@]} -o $output"
    read min_time avg_time max_time <<< $(measure_compile "$cmd")

    # Замер размера
    local binary_size=0
    if [ -f "$output" ]; then
        binary_size=$(du -b "$output" | cut -f1)
    fi

    # Запись в CSV
    echo "$opt,$lto,$min_time,$avg_time,$max_time,$binary_size" >> "$RESULTS_FILE"
    echo " done (avg: ${avg_time} s, size: ${binary_size} bytes)"
}

main() {
    # Находим все исходники
    CPP_FILES=($(find "$SRC_DIR" -name "*.cpp" | sort))
    if [ ${#CPP_FILES[@]} -eq 0 ]; then
        echo "Ошибка: не найдено .cpp файлов в $SRC_DIR!"
        exit 1
    fi

    echo "Найдены исходники: ${CPP_FILES[@]}"

    # Основной цикл
    for opt in "${OPT_LEVELS[@]}"; do
        for i in "${!LTO_MODES[@]}"; do
            compile_all "$opt" "${LTO_MODES[$i]}" "${LTO_FLAGS[$i]}"
        done
    done

    echo "Результаты сохранены в $RESULTS_FILE"
}

main