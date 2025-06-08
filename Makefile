CXX := g++
CXXFLAGS := -Wall -Wextra -pedantic

SRC_DIR := src
BIN_DIR := bin

# Уровни оптимизации
OPT_LEVELS := O0 O1 O2 O3 Oz

# Получаем список всех .cpp файлов в src/
SRC_FILES := $(wildcard $(SRC_DIR)/*.cpp)

# Генерируем список базовых целей (без оптимизации)
BIN_TARGETS := $(patsubst $(SRC_DIR)/%.cpp,$(BIN_DIR)/%,$(SRC_FILES))

# Генерируем список всех возможных целей с оптимизациями
OPT_TARGETS := $(foreach src,$(SRC_FILES),\
                $(foreach opt,$(OPT_LEVELS),\
                $(patsubst $(SRC_DIR)/%.cpp,$(BIN_DIR)/%.$(opt),$(src))))

# Стандартная цель (компилирует все файлы без оптимизации)
all: $(BIN_TARGETS)

# Дополнительная цель для компиляции всех вариантов оптимизации
all-opt: $(OPT_TARGETS)

# Правило для компиляции без оптимизации
$(BIN_DIR)/%: $(SRC_DIR)/%.cpp | $(BIN_DIR)
	$(CXX) $(CXXFLAGS) $< -o $@

# Шаблонное правило для компиляции с оптимизацией
$(BIN_DIR)/%.O0: $(SRC_DIR)/%.cpp | $(BIN_DIR)
	$(CXX) $(CXXFLAGS) -O0 $< -o $@

$(BIN_DIR)/%.O1: $(SRC_DIR)/%.cpp | $(BIN_DIR)
	$(CXX) $(CXXFLAGS) -O1 $< -o $@

$(BIN_DIR)/%.O2: $(SRC_DIR)/%.cpp | $(BIN_DIR)
	$(CXX) $(CXXFLAGS) -O2 $< -o $@

$(BIN_DIR)/%.O3: $(SRC_DIR)/%.cpp | $(BIN_DIR)
	$(CXX) $(CXXFLAGS) -O3 $< -o $@

$(BIN_DIR)/%.Oz: $(SRC_DIR)/%.cpp | $(BIN_DIR)
	$(CXX) $(CXXFLAGS) -Oz $< -o $@

# Создаем директорию bin, если её нет
$(BIN_DIR):
	mkdir -p $(BIN_DIR)

# Запуск всех исполняемых файлов из bin
run-all:
	./scripts/exec_all.sh

# Очистка
clean:
	rm -rf $(BIN_DIR)

# Эти цели не являются реальными файлами
.PHONY: all all-opt clean