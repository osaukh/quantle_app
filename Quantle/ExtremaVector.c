//
//  ExtremaVector.c
//  Quantle
//
//  Created by Olga Saukh on 5/05/17.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2017 Olga Saukh
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#include <stdio.h>
#include <stdlib.h>
#include "ExtremaVector.h"

Extremum* create_extremum(float offset, float amplitude) {
    Extremum *e = malloc(sizeof(Extremum));
    e->offset = offset;
    e->amplitude = amplitude;
    return e;
}

void evector_init(ExtremaVector *vector) {
    // initialize size and capacity
    vector->size = 0;
    vector->capacity = VECTOR_INITIAL_CAPACITY;
    
    // allocate memory for vector->data
    vector->data = malloc(sizeof(Extremum *) * vector->capacity);
}

void evector_append(ExtremaVector *vector, Extremum *value) {
    // make sure there's room to expand into
    evector_double_capacity_if_full(vector);
    
    // append the value and increment vector->size
    vector->data[vector->size++] = value;
}

Extremum* evector_get(ExtremaVector *vector, int index) {
    if (index >= vector->size || index < 0) {
        printf("Index %d out of bounds for vector of size %d\n", index, vector->size);
        exit(1);
    }
    return vector->data[index];
}

void evector_set(ExtremaVector *vector, int index, Extremum *value) {
    // zero fill the vector up to the desired index
    while (index >= vector->size) {
        evector_append(vector, create_extremum(0,0));
    }
    
    // set the value at the desired index
    vector->data[index] = value;
}

void evector_double_capacity_if_full(ExtremaVector *vector) {
    if (vector->size >= vector->capacity) {
        // double vector->capacity and resize the allocated memory accordingly
        vector->capacity *= 2;
        vector->data = realloc(vector->data, sizeof(Extremum *) * vector->capacity);
    }
}

void evector_free(ExtremaVector *vector) {
    free(vector->data);
}
