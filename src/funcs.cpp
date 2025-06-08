#include <complex>

double discriminant (double a, double b, double c) {
    return b * b - 4 * a * c;
}

double root1_compute (double a, double b, double c, double D){
    if (D >= 0)
        return double(-b + sqrt(D)) / (2 * a);
    else
        return NULL;
}

double root2_compute (double a, double b, double c, double D){
    if (D >= 0)
        return double(-b - sqrt(D)) / (2 * a);
    else
        return NULL;
}