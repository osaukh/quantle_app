//
//  ASP.h
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
