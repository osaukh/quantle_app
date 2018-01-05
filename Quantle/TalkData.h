//
//  TalkData.h
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

#import <Foundation/Foundation.h>

/**
 * The Talk class holds all information belonging to a talk, such as speaker name,
 * event title, date, and all possible counts: syllable count, word count, etc.
 */
@interface TalkData  : NSObject <NSCoding>

/**
 * Talk description
 */
// Speaker name.
@property (nonatomic, strong) NSString *speakerName;
// Speaker picture.
@property (nonatomic, strong) NSData *speakerPicture;
// Event name.
@property (nonatomic, strong) NSString *eventName;
// Date of the talk.
@property (nonatomic, strong) NSDate *date;

/**
 * Talk data
 */
// Talk duration.
@property (nonatomic, strong) NSNumber *talkLength;
// Mean rate as syllables per minute.
@property (nonatomic, strong) NSNumber *meanRateAsSyllablesPerMinute;
// Mean rate as words per minute.
@property (nonatomic, strong) NSNumber *meanRateAsWordsPerMinute;
// Mean pitch.
@property (nonatomic, strong) NSNumber *meanPitch;
// Mean volume.
@property (nonatomic, strong) NSNumber *meanVolume;
// Mean pauses per minute.
@property (nonatomic, strong) NSNumber *meanPausesPerMinute;
// Mean pause duration.
@property (nonatomic, strong) NSNumber *meanPauseDuration;
// Total syllables.
@property (nonatomic, strong) NSNumber *totalSyllables;
// Total words.
@property (nonatomic, strong) NSNumber *totalWords;
// Total sentences.
@property (nonatomic, strong) NSNumber *totalSentences;

// Variability rate as syllables per minute.
@property (nonatomic, strong) NSNumber *varRateAsSyllablesPerMinute;
// Variability pitch.
@property (nonatomic, strong) NSNumber *varPitch;
// Variability volume.
@property (nonatomic, strong) NSNumber *varVolume;

/**
 * Plots
 */
// Rate histogram.
@property (nonatomic, strong) NSMutableArray *histRateAsSyllablesPerMinute;
// Word classification.
@property (nonatomic, strong) NSMutableArray *classWordsBySyllables;
// Pause classification.
@property (nonatomic, strong) NSMutableArray *classPausesByLength;
// Pitch histogram.
@property (nonatomic, strong) NSMutableArray *histPitch;
// Volume histogram.
@property (nonatomic, strong) NSMutableArray *histVolume;

/**
 * Comprehension scores
 */
// Flesch Reading Ease: http://simple.wikipedia.org/wiki/Flesch_Reading_Ease
@property (nonatomic, strong) NSNumber *fleschReadingEase;
// Flesch–Kincaid Grade Ease: http://en.wikipedia.org/wiki/Flesch–Kincaid_readability_tests
@property (nonatomic, strong) NSNumber *fleschKincaidGradeEase;
// The Gunning Fog formula: http://en.wikipedia.org/wiki/Readability#The_Gunning_Fog_formula
@property (nonatomic, strong) NSNumber *gunningFogIndex;
// The FORCAST formula: http://en.wikipedia.org/wiki/Readability#The_FORCAST_formula
@property (nonatomic, strong) NSNumber *forecastGradeLevel;

/**
 * Copies all fields related to the talk statistics
 * to the new talk object.
 *
 * @param origin        Original talk to copy from.
 * @param destination   Destination talk to copy to.
 */
+ (void) copyTalkStatistics:(TalkData *)origin destination:(TalkData*)destination;

@end
