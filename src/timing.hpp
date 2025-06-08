#include <iostream>
#include <complex>
#include <chrono>
#include <fstream>
#include <vector>
#include <algorithm>
#include <string>

std::string replace_dots_with_commas(const std::string& input) {
    std::string result = input;
    std::replace(result.begin(), result.end(), '.', ',');
    return result;
}

int write_time_to_csv(  
        const std::string keyword,
        const double vol
    ){
    const std::string csv_filename = "timings.csv";
    const std::string sep = ",";
    // const std::vector<std::string> optimizations = {"O0", "O1", "O2", "O3", "Oz"};
    // const size_t opt_num = optimizations.size();

    std::ofstream csv_file(csv_filename, std::ios::app);
    if (!csv_file.is_open()) {
        std::cerr << "Ошибка открытия файла!" << std::endl;
        return 1;
    }
    
    // Проверяем, пустой ли файл (чтобы добавить заголовок при первом вызове)
    csv_file.seekp(0, std::ios::end);
    bool is_empty = csv_file.tellp() == 0;
    if (is_empty) {
        csv_file << "Name" << sep << "Keyword" << sep << "Optimization" << sep << "Value\n";
    }

    csv_file << replace_dots_with_commas(keyword) << sep << vol << "\n";
    csv_file.close();

    return 0;
}