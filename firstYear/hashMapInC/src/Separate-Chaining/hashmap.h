#ifndef HASHMAP_H
#define HASHMAP_H

typedef struct Node {
    float value;
    struct Node *next;
    char *key;
} Node;

typedef struct hashmap {
    struct Node **table;
    int capacity;
    int length;
} hashmap;

int strToInt(char str[]);
hashmap *initHashMap();
void freeHashMap(hashmap *map);
Node *initNode(char key[], float value);
int hashFunction(char key[], int tableLength);
void insertHashMap(hashmap *map, char key[], float value);
void removeHashMap(hashmap *map, char key[]);
void printHashMap(hashmap *map);
float loadFactor(int capacity, int ength);
void extendHashMap(hashmap *map);
bool isEmptyHashMap(hashmap *map);
float get(hashmap *map, char key[]);

#endif