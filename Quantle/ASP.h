//
//  ASP.h
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

#ifndef Quantle_ASP_h
#define Quantle_ASP_h

#ifdef __cplusplus
extern "C" {
#endif
    
#include <libkern/OSAtomic.h>
#include <string.h>
#include <assert.h>
    
#include "ExtremaVector.h"
#include "TargetConditionals.h"
#include "Utils.h"
    
#define HIST_MAX_VALUES             20
#define MIN_EXTREMA_X_DIFF          512
#define MIN_RELATIVE_STE_DIFF       0.07

#if TARGET_IPHONE_SIMULATOR
    #define DEBUG_OUTPUT
    #define ONE_BUFFER_TIME         (0.0232 / 60 / 2)   // = buffer_len/rate/(sec/min)/channels = 1024 / 44100 / 60 / 2
#else
    #define ONE_BUFFER_TIME         (0.0232 / 60)
#endif
    
    // Talk counters
    struct {
        float talk_duration;
        
        // online counters
        int num_syllables;
        int num_words;
        int num_pauses;
        int num_sentences;
        
        // online mean computation
        float sum_pause_duration;
        
        // classifications and histograms updated online
        int rate_histogram[HIST_MAX_VALUES];   // varies from 100 to 300 with step 4
        int words_by_syllables[4];                  // 1, 2, 3, 4+
        int pauses_by_length[6];                    // [.1-.2], [.2-.4], [.4-.7], [.7-1], [1-1.5], [>1.5]
        int pitch_histogram[HIST_MAX_VALUES];       // varies from 50 to 350 with step 6
        int volume_histogram[HIST_MAX_VALUES];      // varies from 0 to 10 with step 0.2
        
        // comprehension scores, computed after the talk
        float flesch_reading_ease;
        float flesch_kincaid_grade_ease;
        float gunning_fog_index;
        float forecast_grade_level;
    } counters;
    
    void ASP_hard_reset_counters(void);
    void ASP_soft_reset_counters(void);
    
    void ASP_process_buffer(void *buffer, unsigned int len);

    void ASP_syllable_estimation(void *buffer, unsigned int len);
    void ASP_pitch_estimation(void *buffer, unsigned int len);
    void ASP_volume_estimation(float value);
    
    void ASP_inc_talkduration(void);
    void ASP_process_maximum(int index, float value);
    void ASP_process_minimum(int index, float value);
    void ASP_compute_comprehension_scores(void);
    
    void ASP_print(void);
    
#ifdef __cplusplus
}
#endif

#endif
