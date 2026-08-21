# Let's do an associative array in C!

## What's an associative array?

If you're here, I believe you already know about it, but a refresh doesn't hurt. In simple terms, an associative array is `[...] an abstract data type that stores a collection of key/value pairs, such that each possible key appears at most once in the collection. [...] It supports 'lookup', 'remove', and 'insert' operations.` (*according to Wikipedia*).

It's basically like a dictionary in Python, a map in Go, etc.

```python
# Initialize
notes = {
    "Jules" : 19.5,
    "Tom" : 5.0,
    "Noan" : 7.6
}
# Get
print(notes["Jules"]) # 19.5
# Insert
notes["Kiliann"] = 15.4
# Remove
del notes["Tom"]
x = notes.pop("Noan")
print(x) # 7.6
```

The C language doesn't have a natural implementation of this data type, and there are many different ways of writing one. Let's review some of them!

## Different approaches

### Natural approach: Basic linked list

When I first thought about associative arrays in C, my intuitive approach was to implement a linked list with not just the value and next node, but also a key variable.

```c
// Example of a [str] -> [int] map
typedef struct Node {
    char[] key;
    int value;
    struct Node *next;
} Node;
```

The problem with the linked list method lies in its algorithmic cost.

| Operation | Cost |
|-----------|------|
| Insertion | O(1) |
| Get       | O(n) |
| Remove    | O(n) |

For `insertion`, we can simply insert at the beginning of the linked list to achieve O(1) cost. But for `get` and `remove` operations, we must search through the entire linked list, one node at a time, to operate on the right element, resulting in O(n) cost.

If we know the map won't contain too many elements, this can be convenient, but from an algorithmic and learning perspective, it's not really usable.

---

### Hashmap / Hashtable

For years I heard about hashmaps and hashtables without really knowing what they were about. It turns out the concept is fairly simple: instead of searching through every element to find a key, we use a **hash function** to convert the key into an index, and store the value directly at that position in an array.

#### The hash function

The role of the hash function is to convert a key into a valid array index. Here's a basic example:

```c
int strToInt(char str[]) {
    int i = 0, result = 0;
    while (str[i] != '\0') result += (int)str[i++];
    return result;
}

int hashFunction(char key[], int tableLength) {
    return strToInt(key) % tableLength;
}
```

`strToInt` simply sums the ASCII values of each character in the string. Then, the modulo operation ensures the result fits within the bounds of the array.

For example, with a table of length 10:
- `"Jules"` might hash to index `3`
- `"Tom"` might hash to index `7`

| Operation | Cost |
|-----------|------|
| Insertion | O(1) |
| Get       | O(1) |
| Remove    | O(1) |

---

A significant improvement over the linked list! But there's a catch: **collisions**. What happens when two different keys hash to the same index? For example, `"abc"` and `"bca"` have the same ASCII sum, so they would map to the same index. This is where the two main strategies diverge.

No matter how clever your hash function is, collisions will always occur. This is a mathematical certainty known as the **pigeonhole principle**: if you have more possible keys than array slots, at least two keys must inevitably share the same index. A better hash function reduces the frequency of collisions, but it can never eliminate them entirely. That's why every hashmap implementation must have a strategy to handle them.

---

#### Separate chaining

The idea is simple: each slot of the array doesn't hold a single value, but a **linked list** of all the key/value pairs that hashed to that index.

```c
typedef struct Node {
    char key[50];
    int value;
    struct Node *next;
} Node;

Node *table[TABLE_SIZE];
```

When a collision occurs, the new element is simply appended to the list at that slot. A lookup then hashes the key to find the right slot, then walks the list to find the exact key.

```
index 3 -> ["Jules", 19.5] -> ["bca", 42] -> NULL
index 7 -> ["Tom", 5.0] -> NULL
```

The cost stays O(1) on average, but degrades to O(n) in the worst case if many keys collide into the same slot.

If you want to see how I really built it, go check [my implementation](src/Separate-Chaining).

---

#### Open addressing

Instead of using a linked list, open addressing keeps everything **inside the array itself**. When a collision occurs, we probe for the next available slot according to a rule. The simplest rule is **linear probing**: just check the next index, one by one, until an empty slot is found.

```c
typedef struct {
    char key[50];
    int value;
    int occupied;
} Entry;

Entry table[TABLE_SIZE];
```

```
Insert "Jules" -> hash = 3 -> slot 3 is free -> store at 3
Insert "bca"   -> hash = 3 -> slot 3 is taken -> try 4 -> free -> store at 4
```

Lookup works the same way: hash the key, then probe forward until you find a matching key or an empty slot.

---

#### Which one to choose?

| | Separate chaining | Open addressing |
|---|---|---|
| Memory | Extra pointers overhead | Everything in one array |
| Cache performance | Poor (pointer chasing) | Good (contiguous memory) |
| Load factor tolerance | Handles high load well | Degrades past ~70% full |
| Implementation | Slightly simpler | Trickier (deletion is tricky) |

In practice, **open addressing** tends to be faster in cache-friendly scenarios, which is why many modern implementations (like Go's `map` or Python's `dict`) are inspired by it. **Separate chaining** is easier to reason about and more forgiving when the table gets full.