//
//  TalkData.h
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
