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

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// Local extrema algorithm variables
float lmin_elem = 0, lmax_elem = 0, p0_elem = -1, p1_elem = 0;
int lmin_index = 0, lmax_index = 0, p0_index = 0, p1_index = 0, p2_index = 0;

//bool start_over;
float ste, maxste = 0, MIN_EXTREMA_Y_DIFF = 0;
//float ste_window[STE_WINDOW_SIZE];

// needed for pitch computation. We use real-time time-domain pitch tracking using wavelets to compute the pitch
// source: http://www.schmittmachine.com/dywapitchtrack.html
dywapitchtracker dywpt;

// local variables needed for sound normalization. We use adapt volume at runtime.
int buffercounter = 0;

// long-term maxima: 4 x 5s
float volumaxi[4];
int voluindex = -1;

// last 2 pitches
float pitches[3];
int pitchindex=-1;
bool islastnicepitchraw;

int spm_syllables_last_10sec;
float spm_time_last_10sec;

void ASP_hard_reset_counters() {
#if TARGET_IPHONE_SIMULATOR
    printf("SIMULATION\n"); fflush(stdout);
#endif
    
    dywapitch_inittracking(&dywpt);
    
    buffercounter = 0;
    MIN_EXTREMA_Y_DIFF = 0;
    
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
    bzero(&volumaxi, 4*sizeof(float));
    voluindex = -1;
    
    islastnicepitchraw = false;
    bzero(&pitches, 3*sizeof(float));
    pitchindex = 0;
    
    maxste = 0;
    
    spm_syllables_last_10sec = 0;
    spm_time_last_10sec = 0;
}


void ASP_process_buffer(void *buffer, unsigned int len) {
    if (len == 0) return;
    buffercounter++;
    
    // update talk duration and potentially update rate
    ASP_inc_talkduration();
    
    // estimate number of syllables
    ASP_syllable_estimation(buffer, len);
 
    // estimate pitch
    ASP_pitch_estimation(buffer,len);    
}


void ASP_syllable_estimation(void *buffer, unsigned int len) {
    if (voluindex==-1)
        MIN_EXTREMA_Y_DIFF = MIN_RELATIVE_STE_DIFF;
    else
        MIN_EXTREMA_Y_DIFF = MIN_RELATIVE_STE_DIFF * (0.6*volumaxi[voluindex] +
                                                  0.25*volumaxi[(4+voluindex-1)%4] +
                                                  0.1*volumaxi[(4+voluindex-2)%4] +
                                                  0.05*volumaxi[(4+voluindex-3)%4]);
    // compute ste - short-time energy in buffer
    ste = 0;
    for (int i=0; i<len; i++) {
        float element = *((float *) (buffer + i * sizeof(float) ));
        ste += powf(element,2);
    }
    
    /**
     * Syllable recognition algorithm (local extrema finding). Online algorithm.
     * Extremas are either /\ or \/ --> p0[index] - p1[index] - ste_sqrt[i].
     */
    p2_index += len;

    if (p0_elem <= p1_elem && p1_elem <= ste) { p1_elem = ste; p1_index = p2_index; }
    else if (p0_elem <= p1_elem && p1_elem > ste) {
        if ( fabsf(p1_elem-ste) > MIN_EXTREMA_Y_DIFF ) {
            if ((p1_index > MIN_EXTREMA_X_DIFF || p0_elem < 0) && p2_index-p1_index > MIN_EXTREMA_X_DIFF) {

#ifdef DEBUG_OUTPUT
                printf("RateS,%d,%f\n", buffercounter,p1_elem); fflush(stdout);  // local max found: (p1_index, p1_elem)
#endif
                ASP_process_maximum(p1_index, p1_elem);
                    
                lmax_elem = p1_elem; p0_elem = p1_elem; p1_elem = ste;
                float offset = p1_index;
                p0_index = p1_index - offset; p1_index = p2_index - offset; p2_index = p2_index - offset;
            }
        }
    }
    else if (p0_elem >= p1_elem && p1_elem >= ste) { p1_elem = ste; p1_index = p2_index; }
    else if (p0_elem >= p1_elem && p1_elem < ste) {
        if ( fabsf(p1_elem-ste) > MIN_EXTREMA_Y_DIFF ) {
            if ((p1_index > MIN_EXTREMA_X_DIFF || p0_elem < 0) && p2_index-p1_index > MIN_EXTREMA_X_DIFF) {
                
#ifdef DEBUG_OUTPUT
                printf("RateF,%d,%f\n", buffercounter,p1_elem); fflush(stdout); // local min found: (p1_index, p1_elem)
#endif
                ASP_process_minimum(p1_index, p1_elem);
                    
                lmin_elem = p1_elem; p0_elem = p1_elem; p1_elem = ste;
                float offset = p1_index;
                p0_index = p1_index - offset; p1_index = p2_index - offset; p2_index = p2_index - offset;
            }
        }
    }
    
    if (ste > MIN_EXTREMA_Y_DIFF)
        ASP_volume_estimation(ste);
    
    // update 5sec maximum
    maxste = (ste > maxste) ? ste : maxste;
    int buffers_in_five_sec = (int) ((float) 1.0 / ONE_BUFFER_TIME / 20); // one minute contains 1 / ONE_BUFFER_TIME buffers
    if (buffercounter % buffers_in_five_sec == 0) {
        if (voluindex==-1) {
            for (int j=0; j<4; j++)
                volumaxi[j] = maxste;
            voluindex = 0;
        }
        else {
            voluindex = (voluindex+1) % 4;
            volumaxi[ voluindex ] = maxste;
        }
        maxste=0;
    }
    
#ifdef DEBUG_OUTPUT
    printf("STE,%d,%f\n", buffercounter,ste); fflush(stdout);
#endif
}



/**
 *  Update counters
 */
void ASP_inc_talkduration() {
    counters.talk_duration += ONE_BUFFER_TIME;
}

void ASP_pitch_estimation(void *buffer, unsigned int len) {
    float pitch = dywapitch_computepitch(&dywpt, buffer, 0, len);
    pitches[pitchindex % 3] = pitch;
    
    bool nicepitchrow = true;
    for (int i=0; i<2; i++) {
        float p1 = pitches[(pitchindex-i+3) % 3];
        float p2 = pitches[(pitchindex-i-1+3) % 3];
        if ( (p1 < 60 || p1 >= 360) || (p2 < 60 || p2 >= 360) || (fabsf(p1-p2) > 5) )
            nicepitchrow = false;
    }
    
    int start = 2;
    if (nicepitchrow) {
        if (islastnicepitchraw)
            start=0;
        for (int i=start; i>=0; i--) {
#ifdef DEBUG_OUTPUT
            printf("Pitch,%d,%f\n", buffercounter-i,pitches[(pitchindex-i+3) % 3]); fflush(stdout);
#endif
            int idx = (pitches[(pitchindex-i+3) % 3] - 60) / 15;
            counters.pitch_histogram[idx]++;
        }
        islastnicepitchraw = true;
    }
    else
        islastnicepitchraw = false;
    pitchindex++;
}

void ASP_volume_estimation(float value) {
    float volume = 10*log10f(1+value);
#ifdef DEBUG_OUTPUT
    printf("Volume,%d,%f\n", buffercounter,volume); fflush(stdout);
#endif
    volume = (volume < 19) ? volume : 19;
    int idx = volume;
    counters.volume_histogram[idx]++;
}

int wordpart = 0;

// new syllable
void ASP_process_maximum(int index, float value) {
    counters.num_syllables++;
    wordpart++;
    
    // compute rate variability over the past 10s
    spm_syllables_last_10sec++;
    int buffers_in_10sec = (int) ((float) 1.0 / ONE_BUFFER_TIME / 6); // one minute contains 1 / ONE_BUFFER_TIME buffers
    if (buffercounter - spm_time_last_10sec >= buffers_in_10sec) {
        float rate = spm_syllables_last_10sec * 6; // #syllables / 10 sec * 60 sec in one minute
        if (rate < 599 && rate > 0)
            counters.rate_histogram[(int) rate/30]++;
        spm_syllables_last_10sec = 0;
        spm_time_last_10sec = buffercounter;
    }
}

// new pause, new word or gap between syllables in a word
void ASP_process_minimum(int index, float value) {
    float inter_syl_dist = ((float) index) / 44100; // duration in s
    float avg_inter_syl_dist = counters.sum_pause_duration / counters.num_pauses;
    
    // this is a pause between words
    if (inter_syl_dist >= 0.1) {
        counters.num_pauses++;
        counters.sum_pause_duration += inter_syl_dist;
        
        if (inter_syl_dist >= 0.1 && inter_syl_dist < 0.2)
            counters.pauses_by_length[0]++;
        else if (inter_syl_dist >= 0.2 && inter_syl_dist < 0.4)
            counters.pauses_by_length[1]++;
        else if (inter_syl_dist >= 0.4 && inter_syl_dist < 0.7)
            counters.pauses_by_length[2]++;
        else if (inter_syl_dist >= 0.7 && inter_syl_dist < 1)
            counters.pauses_by_length[3]++;
        else if (inter_syl_dist >= 1 && inter_syl_dist < 1.5)
            counters.pauses_by_length[4]++;
        else if (inter_syl_dist >= 1.5)
            counters.pauses_by_length[5]++;
        
        // Increase number of sentences if pause >= factor * average pause length
        if (inter_syl_dist >= avg_inter_syl_dist * 2) // new sentence
            counters.num_sentences++;
    }
    
    // Increase number of words
    if (inter_syl_dist >= 0.125 * avg_inter_syl_dist) {
        counters.num_words++;
        counters.words_by_syllables[(wordpart>4) ? 3 : wordpart-1]++;
        wordpart = 0;
    }
}


float fit_to_interval(float value, float from, float to) {
    value = value < from ? from : value;
    value = value > to ? to : value;
    return value;
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
