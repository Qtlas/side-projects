#!/bin/bash

gcc -g -fsanitize=address -fno-omit-frame-pointer -o main main.c hashmap.c
chmod +x main
./main
