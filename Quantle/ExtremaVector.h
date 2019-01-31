//
//  ExtremaVector.h
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
