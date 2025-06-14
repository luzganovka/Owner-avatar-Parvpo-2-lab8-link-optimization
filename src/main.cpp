#include <iostream>
#include <chrono>
#include <complex>
#include "timing.hpp"

double discriminant (double a, double b, double c);
double root2_compute (double a, double b, double c, double D);
double root1_compute (double a, double b, double c, double D);

void solveQuadratic(double a, double b, double c, double* res) {
    if (a == 0) {
        if (b == 0) {
            if (c == 0) {
                // std::cout << "Уравнение имеет бесконечно много решений." << std::endl;
                return;
            } else {
                // std::cout << "Уравнение не имеет решений." << std::endl;
                return;
            }
        } else {
            // Линейное уравнение bx + c = 0
            double root = -c / b;
            *res += root + root;
            // std::cout << "Корень линейного уравнения: " << root << std::endl;
            return;
        }
    }

    double D = discriminant(a, b, c);

    double root1 = root1_compute(a, b, c, D);
    double root2 = root2_compute(a, b, c, D);
    *res += root1 + root2;
    // std::cout << "Два корня: " << root1 << " и " << root2 << std::endl;
    return;
}

int main(int argc, char* argv[]) {
    if (argc != 3) {
        std::cerr << "Usage: " << argv[0] << " <statistics_num> <runs_num>\n";
        return 1;
    }
    int statistics_num = atoi(argv[1]);
    int runs_num = atoi(argv[2]);
    std::chrono::duration<double> duration;
    double avg = 0.0;
    srand(42);
    double res = .0;


    for (int i = 0; i < statistics_num; i++){
        auto start = std::chrono::high_resolution_clock::now();

        int _ = 0;
        while (_ < runs_num) {
            _++;
            double a = rand() % 100 + 1;    // 1 - 100
            double b = rand() % 201 - 100;  // -100 - 100
            double c = rand() % 201 - 100;  // -100 - 100
            solveQuadratic(a, b, c, &res);    
        }

        auto end = std::chrono::high_resolution_clock::now();
        duration = end - start;
        avg = avg + duration.count();
        if(i % ((int)(statistics_num/10)) == 0){std::cout << "iteration " << i << " | duration = " << duration.count() << "; summ = " << avg << std::endl;}
    }
    std::cout << "result: " << res << std::endl; // только для того, чтобы компилятор не выкинул все вычисления
    avg /= statistics_num;
    std::cout << avg << " секунд" << std::endl;

    write_time_to_csv(argv[0], avg);

    return 0;
}