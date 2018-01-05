//
//  OngoingTalk.m
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

#import "OngoingTalk.h"

@implementation OngoingTalk

static TalkData *td;

+ (TalkData*)getInstance {
    if (td == nil) {
        td = [[TalkData alloc] init];
        
        td.speakerName = @"Alice Armstrong";
        td.speakerPicture = UIImagePNGRepresentation([UIImage imageNamed:@"face32x32.png"]);
        td.eventName = @"Sample Talk";
        td.date = [NSDate date];
        
        zeroFields();
    }
    return td;
}

void zeroFields () {
    td.talkLength = 0;
    
    td.meanRateAsSyllablesPerMinute = 0;
    td.meanRateAsWordsPerMinute = 0;
    td.meanPitch = 0;
    td.meanVolume = 0;
    td.meanPausesPerMinute = 0;
    td.meanPauseDuration = 0;
    
    td.totalSyllables = 0;
    td.totalWords = 0;
    td.totalSentences = 0;
    
    td.varRateAsSyllablesPerMinute = 0;
    td.varPitch = 0;
    td.varVolume = 0;
    
    td.histRateAsSyllablesPerMinute = [[NSMutableArray alloc] init];
    td.classWordsBySyllables = [[NSMutableArray alloc] init];
    td.classPausesByLength = [[NSMutableArray alloc] init];
    td.histPitch = [[NSMutableArray alloc] init];
    td.histVolume = [[NSMutableArray alloc] init];
    
    td.fleschReadingEase = 0;
    td.fleschKincaidGradeEase = 0;
    td.gunningFogIndex = 0;
    td.forecastGradeLevel = 0;
}

+ (TalkData*)resetInstance {
    if (td == nil)
        td = [[TalkData alloc] init];
    
    td.speakerPicture = UIImagePNGRepresentation([UIImage imageNamed:@"face32x32.png"]);
    td.date = [NSDate date];
    
    zeroFields();
    return td;
}

+(TalkData*) resetTime {
    td.date = [NSDate date];
    
    return td;
}

+(TalkData*) setInstance {
    // Update all counters
    
    // counters
    td.talkLength = @( counters.talk_duration );
    td.totalSyllables = @( counters.num_syllables );
    td.totalWords = @( counters.num_words );
    td.totalSentences = @( counters.num_sentences );
    
    // rate
    if (counters.talk_duration)
        td.meanRateAsSyllablesPerMinute = @( counters.num_syllables / counters.talk_duration );
    if (counters.talk_duration)
        td.meanRateAsWordsPerMinute = @( counters.num_words / counters.talk_duration );
    [OngoingTalk setRateData];
    
    // pauses
    if (counters.talk_duration)
        td.meanPauseDuration = @( counters.sum_pause_duration / counters.talk_duration / 60);
    
    // pitch
    [OngoingTalk setPitchData];
    
    // volume
    [OngoingTalk setVolumeData];
    
    // histograms and classifications
    for (int i=0; i<HIST_MAX_VALUES; i++)
        [td.histRateAsSyllablesPerMinute addObject:@(counters.rate_histogram[i])];
    for (int i=0; i<4; i++)
        [td.classWordsBySyllables addObject:@(counters.words_by_syllables[i])];
    for (int i=0; i<6; i++)
        [td.classPausesByLength addObject:@(counters.pauses_by_length[i])];
    for (int i=0; i<HIST_MAX_VALUES; i++)
        [td.histPitch addObject:@(counters.pitch_histogram[i])];
    for (int i=0; i<HIST_MAX_VALUES; i++)
        [td.histVolume addObject:@(counters.volume_histogram[i])];
    
    // comprehension scores
    ASP_compute_comprehension_scores();
    td.fleschReadingEase = @( counters.flesch_reading_ease );
    td.fleschKincaidGradeEase = @( counters.flesch_kincaid_grade_ease );
    td.gunningFogIndex = @( counters.gunning_fog_index );
    td.forecastGradeLevel = @( counters.forecast_grade_level );
    
    return td;
}

+(void) setPitchData {
    int num_pitch = 0, sum_pitch = 0;
    for (int i=0; i<HIST_MAX_VALUES; i++) {
        sum_pitch += (counters.pitch_histogram[i] * (i * 15 + 60));
        num_pitch += counters.pitch_histogram[i];
    }
    td.meanPitch = (num_pitch > 0) ? @( sum_pitch / num_pitch ) : @(0);
    
    // find var
    float rmse = 0;
    for (int i=0; i<HIST_MAX_VALUES; i++)
        rmse += ( powf(i-(td.meanPitch.intValue-60)/15,2) * 36 ) * counters.pitch_histogram[i];
    td.varPitch = (num_pitch > 0) ? @( sqrtf(rmse / num_pitch) / 150*100 ) : @(0);
}

+(void) setRateData {
    int num_rate = 0, q50 = 0;
    // find 50% quantile
    for (int i=0; i<HIST_MAX_VALUES; i++)
        num_rate += counters.rate_histogram [i];
    
    int tmp_sum = 0;
    for (q50=0; q50<HIST_MAX_VALUES; q50++) {
        tmp_sum += counters.rate_histogram[q50];
        if (tmp_sum > .5 * num_rate)
            break;
    }
    // find var
    float rmse = 0;
    for (int i=0; i<HIST_MAX_VALUES; i++)
        rmse += ( powf(i-q50,2) * 144 ) * counters.rate_histogram[i];
    td.varRateAsSyllablesPerMinute = (num_rate > 0) ? @( sqrtf(rmse / num_rate) / 300*100) : @(0);
}

+(void) setVolumeData {
    int num_volume = 0, q50 = 0;
    // find 50% quantile
    for (int i=0; i<HIST_MAX_VALUES; i++)
        num_volume += counters.volume_histogram[i];
    
    int tmp_sum = 0;
    for (q50=0; q50<HIST_MAX_VALUES; q50++) {
        tmp_sum += counters.volume_histogram[q50];
        if (tmp_sum > .5 * num_volume)
            break;
    }
    td.meanVolume = (num_volume > 0) ? @( ((float) q50) ) : @(0);
    // find var
    float rmse = 0;
    for (int i=0; i<HIST_MAX_VALUES; i++)
        rmse += ( powf(i-q50,2) ) * counters.volume_histogram[i];
    td.varVolume = (num_volume > 0) ? @( sqrtf(rmse / num_volume) / 25*100 ) : @(0);
}


@end
