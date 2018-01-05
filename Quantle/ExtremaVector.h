//
//  ExtremaVector.h
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

#ifndef __Quantle__ExtremaVector__
#define __Quantle__ExtremaVector__

#include <stdio.h>

#define VECTOR_INITIAL_CAPACITY 100

// Talk profile structure
typedef struct {
    float offset;
    float amplitude;
} Extremum;

Extremum* create_extremum(float offset, float amplitude);

// Define a vector type
typedef struct {
    int size;      // slots used so far
    int capacity;  // total available slots
    Extremum **data;     // array of integers we're storing
} ExtremaVector;

void evector_init(ExtremaVector *vector);

void evector_append(ExtremaVector *vector, Extremum *value);

Extremum* evector_get(ExtremaVector *vector, int index);

void evector_set(ExtremaVector *vector, int index, Extremum *value);

void evector_double_capacity_if_full(ExtremaVector *vector);

void evector_free(ExtremaVector *vector);

#endif /* defined(__Quantle__Vector__) */
