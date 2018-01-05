//
//  ExtremaVector.c
//  Quantle
//
//  Created by Olga Saukh on 5/05/17.
//  Copyright (c) 2017 chatterboxbit.com. All rights reserved.
//
//  Quantle is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Quantle is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Quantle.  If not, see <http://www.gnu.org/licenses/>.
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
