//
//  APS.c
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

#include "ASP.h"
#include "dywapitchtrack.h"
#include "subbandpath.h"

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// Number of processed buffers
int buffercounter = 0;

// Real-time time-domain pitch tracking using wavelets to compute the pitch
// Source: http://www.schmittmachine.com/dywapitchtrack.html (Unfortunately, no more available)
dywapitchtracker dywpt;

// Local extrema algorithm variables
float p0_elem = -1, p1_elem = 0;
int p0_index = 0, p1_index = 0, p2_index = 0;
int wordpart = 0;



float fit_to_interval(float value, float from, float to) {
    value = value < from ? from : value;
    value = value > to ? to : value;
    return value;
}

void ASP_hard_reset_counters() {
#if TARGET_IPHONE_SIMULATOR
    printf("SIMULATION\n"); fflush(stdout);
#endif
    
    buffercounter = 0;
    dywapitch_inittracking(&dywpt);
    
    counters.talk_duration = 0;
    counters.num_syllables = 0;
    counters.num_words = 0;
    counters.num_pauses = 0;
    counters.num_sentences = 0;
    
    counters.sum_pause_duration = 0;
    
    bzero(&counters.rate_histogram, 20*sizeof(int));
    bzero(&counters.words_by_syllables, 4*sizeof(int));
    bzero(&counters.pauses_by_length, 6*sizeof(int));
    bzero(&counters.pitch_histogram, 20*sizeof(int));
    bzero(&counters.volume_histogram, 20*sizeof(int));
    
    ASP_soft_reset_counters();
}


void ASP_soft_reset_counters() {
}


void ASP_process_buffer(void *buffer, unsigned int len) {
    if (len == 0) return;
    buffercounter++;
    
    // update talk duration and potentially update rate
    ASP_inc_talkduration();

    // estimate pitch
    float p = ASP_pitch_estimation(buffer,len);
    
    // estimate number of syllables
    ASP_syllable_estimation(buffer, len, p);
    
    // estimate volume
    ASP_volume_estimation(buffer, len);
 }

float repart[ONE_BUFFER_LEN];
float impart[ONE_BUFFER_LEN];

void ASP_syllable_estimation(void *buffer, unsigned int len, float pitch) {
    bcopy(buffer, &repart, ONE_BUFFER_LEN*sizeof(float));
    for (int i=0; i<len; i++)
        repart[i] = (float) ((float *) buffer)[i];
    bzero(&impart, ONE_BUFFER_LEN*sizeof(float));
    FFT(1, ONE_BUFFER_LEN, (float *) &repart, (float *) &impart);
    
//    for (int i=0; i<len; i++) {
//        printf("%f, ", ((float *) repart)[i]);
//    }
//    printf("----\n\n");
//    fflush(stdout);
    
    // Algorithm: https://ieeexplore.ieee.org/document/4317582/ (Subband-Based Correlation Approach)
    // Step 1: Morgan and Fosler-Lussier, compute a trajectory that is the average product over all pairs of compressed sub-band energy trajectories.
    // Use 4 bands max, otherwise NON-real-time (quadratic computational complexity)
    float y = 0;
    int n_bands = 20;
    int L = ONE_BUFFER_LEN / 2 / n_bands;
    for (int i=0; i<n_bands-1; i++) {
        for (int j=i+1; j<n_bands; j++) {
            float sum_i = 0;
            float sum_j = 0;
            for (int k=i*L; k<i*L+L; k++)
                sum_i += powf( ((float *) repart)[k], 2);
            for (int k=j*L; k<j*L+L; k++)
                sum_j += powf( ((float *) repart)[k], 2);
            y += sum_i * sum_j;
        }
    }
//    printf("%f, ",y); fflush(stdout);

    // Step 2: Syllable recognition algorithm (local extrema finding). Online algorithm.
    // Extremas are either /\ or \/ --> Estimated by: p0_elem --> p1_elem --> y.
    float MIN_EXTREMA_Y_DIFF = 0;
    
    p2_index += len;
    if (p0_elem <= p1_elem && p1_elem <= y) { p1_elem = y; p1_index = p2_index; }
    else if (p0_elem <= p1_elem && p1_elem > y && pitch >= 60 && pitch < 400) {
        if ( fabsf(p1_elem-y) > MIN_EXTREMA_Y_DIFF ) {
            if ((p1_index > MIN_EXTREMA_X_DIFF || p0_elem < 0) && p2_index-p1_index > MIN_EXTREMA_X_DIFF) {
#ifdef DEBUG_OUTPUT
                printf("RateS,%d,%f\n", buffercounter,p1_elem); fflush(stdout);  // local max found: (p1_index, p1_elem)
#endif
                ASP_process_maximum(p1_index, p1_elem);
                    
                p0_elem = p1_elem; p1_elem = y;
                float offset = p1_index;
                p0_index = p1_index - offset; p1_index = p2_index - offset; p2_index = p2_index - offset;
            }
        }
    }
    else if (p0_elem >= p1_elem && p1_elem >= y) { p1_elem = y; p1_index = p2_index; }
    else if (p0_elem >= p1_elem && p1_elem < y) {
        if ( fabsf(p1_elem-y) > MIN_EXTREMA_Y_DIFF ) {
            if ((p1_index > MIN_EXTREMA_X_DIFF || p0_elem < 0) && p2_index-p1_index > MIN_EXTREMA_X_DIFF) {
                
#ifdef DEBUG_OUTPUT
                printf("RateF,%d,%f\n", buffercounter,p1_elem); fflush(stdout); // local min found: (p1_index, p1_elem)
#endif
                ASP_process_minimum(p1_index, p1_elem);
                    
                p0_elem = p1_elem; p1_elem = y;
                float offset = p1_index;
                p0_index = p1_index - offset; p1_index = p2_index - offset; p2_index = p2_index - offset;
            }
        }
    }
}

// new syllable
void ASP_process_maximum(int index, float value) {
    counters.num_syllables++;
    wordpart++;
}


// new pause, new word or gap between syllables in a word
void ASP_process_minimum(int index, float value) {
    // duration between the end of previous syllable and the beginning of the next one
    float pause = ((float) index) / 44100 ;
    float avg_pause = counters.sum_pause_duration / counters.num_pauses;
    
    // pause if greater than 0.1
    if (pause >= 0.1) {
        counters.num_pauses++;
        counters.sum_pause_duration += pause;

        // pause classification according to the literature (a bit more detailed): http://sixminutes.dlugan.com/pause-speech/
        if (pause >= 0.1 && pause < 0.2)
        counters.pauses_by_length[0]++;
        else if (pause >= 0.2 && pause < 0.4)
        counters.pauses_by_length[1]++;
        else if (pause >= 0.4 && pause < 0.7)
        counters.pauses_by_length[2]++;
        else if (pause >= 0.7 && pause < 1)
        counters.pauses_by_length[3]++;
        else if (pause >= 1 && pause < 1.5)
        counters.pauses_by_length[4]++;
        else if (pause >= 1.5)
        counters.pauses_by_length[5]++;
        
        // Increase number of sentences if pause >= factor * average pause length
        if (pause >= avg_pause * 2) // new sentence
        counters.num_sentences++;
        
        // Update rate histogram
        float rate = 60 / avg_pause; //( pause * 0.3 + avg_pause * 0.7);
        rate = (rate < 599) ? rate : 599;
        int idx = (rate) / 30;
        counters.rate_histogram[idx]++;
    }
    
    // Increase number of words
    if (pause >= avg_pause / 4) {
        counters.num_words++;
        counters.words_by_syllables[(wordpart>4) ? 3 : wordpart-1]++;
        wordpart = 0;
    }
}



void ASP_inc_talkduration() {
    counters.talk_duration += ONE_BUFFER_TIME;
}


float ASP_pitch_estimation(void *buffer, unsigned int len) {
    float pitch = dywapitch_computepitch(&dywpt, buffer, 0, len);
    
    if (pitch > 60 && pitch < 360) {
        counters.pitch_histogram[ (int) ((pitch - 60) / 15) ]++;
#ifdef DEBUG_OUTPUT
        printf("Pitch,%d,%f\n", buffercounter, pitch); fflush(stdout);
#endif
    }
    return pitch;
}


void ASP_volume_estimation(void *buffer, unsigned int len) {
    float ste = 0;
    for (int i=0; i<len; i++) {
        ste += powf( ((float *) buffer)[i], 2);
    }

    float volume = 20*log10f( sqrtf(ste) * 10000 + 100 );
#ifdef DEBUG_OUTPUT
    printf("Volume,%d,%f\n", buffercounter,volume); fflush(stdout);
#endif
    int idx = fit_to_interval( (volume - 40) / 3, 0, 19);
    counters.volume_histogram[idx]++;
}


void ASP_compute_comprehension_scores() {
    // Flesch Reading Ease
    counters.flesch_reading_ease = 0;
    if (counters.num_words && counters.num_sentences) {
        counters.flesch_reading_ease = 206.835 - 1.015 * ((float) counters.num_words)/counters.num_sentences -
            84.6 * ((float) counters.num_syllables)/counters.num_words;
        counters.flesch_reading_ease = fit_to_interval(counters.flesch_reading_ease, 0, 100);
    }

    // Flesch-Kincaid Grade Ease
    counters.flesch_kincaid_grade_ease = 0;
    if (counters.num_sentences && counters.num_words) {
        counters.flesch_kincaid_grade_ease = 0.39 * ((float) counters.num_words)/counters.num_sentences +
            11.8 * ((float) counters.num_syllables)/counters.num_words - 15.59;
        counters.flesch_kincaid_grade_ease = fit_to_interval(counters.flesch_kincaid_grade_ease, 0, 20);
    }

    // Gunning Fog Index
    int num_hard_words = counters.words_by_syllables[2] + counters.words_by_syllables[3];
    counters.gunning_fog_index = 0;
    if (counters.num_sentences && counters.num_words) {
        counters.gunning_fog_index = 0.4 * ( ((float) counters.num_words)/counters.num_sentences +
                                            ((float) num_hard_words)/counters.num_words );
        counters.gunning_fog_index = fit_to_interval(counters.gunning_fog_index, 0, 20);
    }

    // Forecast Grade Level
    counters.forecast_grade_level = 0;
    if (counters.num_words) {
        counters.forecast_grade_level = 20 - 15 * ((float) counters.words_by_syllables[0])/counters.num_words;
        counters.forecast_grade_level = fit_to_interval(counters.forecast_grade_level, 0, 20);
    }
}

void ASP_print() {
    // q_length, q_syllables, q_words, q_sentences
    printf("%f,%d,%d,%d\n", counters.talk_duration,
           counters.num_syllables, counters.num_words, counters.num_sentences); fflush(stdout);
}
