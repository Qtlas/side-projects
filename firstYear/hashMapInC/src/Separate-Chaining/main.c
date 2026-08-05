#include <stdio.h>
#include "hashmap.h"



int main() {
    printf("Hashmap in C ! (using chain method))\n\n");
    hashmap *map = initHashMap();

    char *mathematiciens[] = {"Euclide", "Archimede", "Euler", "Gauss", "Cauchy", "Riemann", "Poincare", "Hilbert", "Noether", "Turing"};
    float dates_naissance[] = {-325, -287, 1707, 1777, 1789, 1826, 1854, 1862, 1882, 1912};

    for (int i = 0; i < 10; i++) {
        insertHashMap(map, mathematiciens[i], dates_naissance[i]);
    }
    
    printHashMap(map);
    printf("\nEuler is born in %0.0f\n", get(map, "Euler")); //The best leave first
    printf("Load factor is : %0.3f\n", loadFactor(map->capacity, map->length));

    removeHashMap(map, "Euler");
    printf("%f", get(map, "Euler"));
    freeHashMap(map);

    return 0;
}