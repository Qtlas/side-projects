#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "hashmap.h"

#define INIT_ARRAY_SIZE 8

int strToInt(char str[]) {
    int i=0, result=0;
    while(str[i] != '\0') result += (int)str[i++];
    return result; 
}

Node *initNode(char key[], float value) {
    Node *newNode = malloc(sizeof(Node));
    newNode->key =  malloc(strlen(key) + 1);

    strcpy(newNode->key, key);

    newNode->value = value;
    newNode->next = NULL;

    return newNode;
}

hashmap *initHashMap() {
    Node **table = malloc(sizeof(Node *) * INIT_ARRAY_SIZE);
    hashmap *map = malloc(sizeof(*map));

    if (table == NULL || map == NULL) {
        printf("Errors using malloc -> consider check u're pc <3");
        exit(1);
    }

    map->capacity = INIT_ARRAY_SIZE;
    map->length = 0;

    for(int i=0; i<INIT_ARRAY_SIZE; i++) {
        table[i] = NULL;
    }

    map->table = table;

    return map;
}


bool isEmptyHashMap(hashmap *map) {
    return map->length == 0;
}


void freeHashMap(hashmap *map) {
    Node *temp = NULL;

    for (int i=0; i < map->capacity; i++) {
        while(map->table[i] != NULL) {
            temp = map->table[i]->next;
            free(map->table[i]->key);
            free(map->table[i]);
            map->table[i] = temp;
        }
    }

    free(map->table);
    free(map);
    map = NULL;

}

int hashFunction(char key[], int tableLength) {
    return strToInt(key) % tableLength;
}


void printHashMap(hashmap *map) {
    for (int i=0; i < map->capacity; i++) {
        if (map->table[i] != NULL) {
            Node *temp = map->table[i];
            while(temp != NULL) {
                printf("%s : %.2f\n", temp->key, temp->value);
                temp = temp->next;
            }
        }
    }
}


void insertHashMap(hashmap *map, char key[], float value) {
    
    if (loadFactor(map->capacity, map->length) >= 0.75) extendHashMap(map);

    bool updateLength = true;

    int index = hashFunction(key, map->capacity);
    Node *temp = map->table[index];

    if (temp == NULL) {
        map->table[index] = initNode(key, value);
    } else {
        while (strcmp(temp->key, key) != 0 && temp->next != NULL) {
            temp = temp->next;
        }

        if (strcmp(temp->key, key) == 0) {
            temp->value = value;
            updateLength = false;
        } else {
            temp->next = initNode(key, value);
        }
    }

    if (updateLength) map->length++;

}


float get(hashmap *map, char key[]) {
    if (isEmptyHashMap(map)) return NAN;
    int index = hashFunction(key, map->capacity);
    Node *temp = map->table[index];

    while(temp != NULL && strcmp(temp->key, key) != 0) {
        temp = temp->next;
    }

    if (temp == NULL) {
        return NAN;
    } else {
        return temp->value;
    }
}


void removeHashMap(hashmap *map, char key[]) {

    int index = hashFunction(key, map->capacity);
    Node *temp = map->table[index];
    

    if (temp == NULL) {
        printf("Can't delete if key dont belong to this map");
        exit(1);
    } else if (strcmp(temp->key, key) == 0) {
        map->table[index] = temp->next;
        free(temp->key);
        free(temp);
    } else {
        while (temp->next != NULL && strcmp(temp->next->key, key) != 0 ) {
            temp = temp->next;
        }

        if (temp->next == NULL) {
            printf("Can't delete if key dont belong to this map");
            exit(1);
        } else {
            Node *toDelete = temp->next;
            temp->next = toDelete->next;
            free(toDelete->key);
            free(toDelete);
        }
    }

    map->length--;
}
float loadFactor(int capacity, int length) {
    return capacity > 0 ? (float)length / capacity : 0.0;
}

void extendHashMap(hashmap *map) {
    int newCapacity = map->capacity * 2;
    Node **newTable = malloc(sizeof(Node *) * newCapacity);
    if (newTable == NULL) {
        printf("Errors using malloc -> consider check u're pc <3\n");
        exit(1);
    }

    for (int i = 0; i < newCapacity; i++) {
        newTable[i] = NULL;
    }

    for (int i = 0; i < map->capacity; i++) {
        Node *temp = map->table[i];
        while (temp != NULL) {
            Node *next = temp->next;      
            int newIndex = hashFunction(temp->key, newCapacity);

            temp->next = newTable[newIndex];
            newTable[newIndex] = temp;

            temp = next;                 
        }
    }

    free(map->table);   
    map->table = newTable;
    map->capacity = newCapacity;
}



