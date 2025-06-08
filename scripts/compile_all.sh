#!/bin/bash

CXX="clang++"
CXXFLAGS="-Wall -Wextra -pedantic"
SRC_DIR="src"
BIN_DIR="bin"
RESULTS_FILE="external_times.csv"
ITERATIONS=10  # Количество запусков для усреднения

# Уровни оптимизации
OPT_LEVELS=("O0" "O1" "O2" "O3" "Oz")

# Режимы LTO
LTO_MODES=("no-lto" "thin-lto" "full-lto")
LTO_FLAGS=("" "-flto=thin" "-flto")

mkdir -p "$BIN_DIR"

# Заголовок CSV
echo "Source File,Optimization Level,LTO Mode,Min Time (s),Avg Time (s),Max Time (s),Binary Size (Bytes)" > "$RESULTS_FILE"

# Функция для замера времени (использует time)
measure_compile() {
    local cmd="$1"
    local total=0
    local min_time=9999
    local max_time=0

    for ((i=1; i<=ITERATIONS; i++)); do
        # Чистим кеш компилятора (если поддерживается)
        if command -v ccache &> /dev/null; then
            ccache -C >/dev/null
        fi

        # Замеряем время через time
        local time_output
        time_output=$( { time -p $cmd >/dev/null 2>&1; } 2>&1 )
        local real_time=$(echo "$time_output" | grep real | awk '{print $2}')

        # Обновляем min/max/total
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

measure_everything() {
    local src_file="$1"
    local opt="$2"
    local lto="$3"
    local lto_flag="$4"
    local base_name=$(basename "$src_file" .cpp)
    local output="$BIN_DIR/$base_name.$opt.$lto"

    echo -n "Building $base_name with -$opt $lto (${ITERATIONS}x)..."

    # Удаляем старый бинарник (если есть)
    rm -f "$output"

    # Замер времени
    local cmd="$CXX $CXXFLAGS -$opt $lto_flag $src_file -o $output"
    read min_time avg_time max_time <<< $(measure_compile "$cmd")

    # Замер размера бинарника
    local binary_size=0
    if [ -f "$output" ]; then
        binary_size=$(du -b "$output" | cut -f1)
    fi

    # Запись в CSV
    echo "$base_name,$opt,$lto,$min_time,$avg_time,$max_time,$binary_size" >> "$RESULTS_FILE"
    echo " done (avg: ${avg_time}s, size: ${binary_size}Bytes)"
}

# Основной цикл
src_file = "src/main.cpp src/funcs.cpp"
for src_file in "$SRC_DIR"/*.cpp; do
    if [ -f "$src_file" ]; then
        for opt in "${OPT_LEVELS[@]}"; do
            for i in "${!LTO_MODES[@]}"; do
                measure_everything "$src_file" "$opt" "${LTO_MODES[$i]}" "${LTO_FLAGS[$i]}"
            done
        done
    fi
done

echo "Results saved to $RESULTS_FILE"