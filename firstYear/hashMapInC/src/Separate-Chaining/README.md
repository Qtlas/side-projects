# My separate chaining implementation

This folder has my real C code for the hashmap I talk about in the [main article](../../README.md). Here I explain how it works in simple words.

## The structures

A `Node` is one entry in the map. It has a key, a value, and a pointer to the next node (this is how we make the chain for collisions).

```c
typedef struct Node {
    float value;
    struct Node *next;
    char *key;
} Node;
```

The `hashmap` struct holds the array of nodes (`table`), how many slots it has (`capacity`), and how many keys are stored (`length`).

```c
typedef struct hashmap {
    struct Node **table;
    int capacity;
    int length;
} hashmap;
```

## How insert works

`insertHashMap` first checks the load factor (how full the table is). If it is 0.75 or more, it grows the table before inserting anything new (see "Growing the table" below).

Then it hashes the key to get an index. If that slot is empty, it just puts the new node there. If the slot already has a chain, it walks the chain:
- if it finds the same key, it updates the value (no new node, so `length` does not go up)
- if it reaches the end without finding the key, it adds a new node at the end of the chain

## How get and remove work

`get` hashes the key, goes to that slot, then walks the chain and compares each key with `strcmp` until it finds a match. If it never finds it, it returns `NAN`.

`removeHashMap` does the same walk, but it also has to fix the chain around the node it deletes (the node before it needs to point to the node after it), then it frees the memory of that node.

## Growing the table

When the table gets too full, `extendHashMap` doubles the capacity. It cannot just copy the old array into a bigger one, because the hash function uses the capacity to compute the index (`key % capacity`). So a bigger capacity means every key can land on a different index.

To fix this, the function creates a new empty table, then goes through every old node and re-inserts it in the new table using the new capacity. This is why growing a hashmap is a bit expensive: every key gets re-hashed once.

## Files

- `hashmap.h` : the structures and function declarations
- `hashmap.c` : all the logic explained above
- `main.c` : a small demo that inserts 10 mathematicians with their birth year, prints the map, looks up one key, and removes it
- `run.sh` : compiles with address sanitizer and runs the demo

## Try it

```bash
bash run.sh
```

This compiles `main.c` and `hashmap.c` together with `-fsanitize=address`, so you also catch memory bugs while testing.
