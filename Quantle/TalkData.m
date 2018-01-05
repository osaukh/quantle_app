//
//  TalkData.m
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

#import "TalkData.h"

@implementation TalkData


#pragma mark NSCoding

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.speakerName forKey:@"speakerName"];
    [encoder encodeObject:self.speakerPicture forKey:@"speakerPicture"];
    [encoder encodeObject:self.eventName forKey:@"eventName"];
    [encoder encodeObject:self.date forKey:@"date"];
    
    [encoder encodeObject:self.talkLength forKey:@"talkLength"];
    
    [encoder encodeObject:self.meanRateAsSyllablesPerMinute forKey:@"meanRateAsSyllablesPerMinute"];
    [encoder encodeObject:self.meanRateAsWordsPerMinute forKey:@"meanRateAsWordsPerMinute"];
    [encoder encodeObject:self.meanPitch forKey:@"meanPitch"];
    [encoder encodeObject:self.meanVolume forKey:@"meanVolume"];
    [encoder encodeObject:self.meanPausesPerMinute forKey:@"meanPausesPerMinute"];
    [encoder encodeObject:self.meanPauseDuration forKey:@"meanPauseDuration"];
    
    [encoder encodeObject:self.totalSyllables forKey:@"totalSyllables"];
    [encoder encodeObject:self.totalWords forKey:@"totalWords"];
    [encoder encodeObject:self.totalSentences forKey:@"totalSentences"];
    
    [encoder encodeObject:self.varRateAsSyllablesPerMinute forKey:@"varRateAsSyllablesPerMinute"];
    [encoder encodeObject:self.varPitch forKey:@"varPitch"];
    [encoder encodeObject:self.varVolume forKey:@"varVolume"];
    
    [encoder encodeObject:self.histRateAsSyllablesPerMinute forKey:@"histRateAsSyllablesPerMinute"];
    [encoder encodeObject:self.classWordsBySyllables forKey:@"classWordsBySyllables"];
    [encoder encodeObject:self.classPausesByLength forKey:@"classPausesByLength"];
    [encoder encodeObject:self.histPitch forKey:@"histPitch"];
    [encoder encodeObject:self.histVolume forKey:@"histVolume"];
    
    [encoder encodeObject:self.fleschReadingEase forKey:@"fleschReadingEase"];
    [encoder encodeObject:self.fleschKincaidGradeEase forKey:@"fleschKincaidGradeEase"];
    [encoder encodeObject:self.gunningFogIndex forKey:@"gunningFogIndex"];
    [encoder encodeObject:self.forecastGradeLevel forKey:@"forecastGradeLevel"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    //  create talk data object
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.speakerName = [decoder decodeObjectForKey:@"speakerName"];
    self.speakerPicture = [decoder decodeObjectForKey:@"speakerPicture"];
    self.eventName = [decoder decodeObjectForKey:@"eventName"];
    self.date = [decoder decodeObjectForKey:@"date"];

    self.talkLength = [decoder decodeObjectForKey:@"talkLength"];

    self.meanRateAsSyllablesPerMinute = [decoder decodeObjectForKey:@"meanRateAsSyllablesPerMinute"];
    self.meanRateAsWordsPerMinute = [decoder decodeObjectForKey:@"meanRateAsWordsPerMinute"];
    self.meanPitch = [decoder decodeObjectForKey:@"meanPitch"];
    self.meanVolume = [decoder decodeObjectForKey:@"meanVolume"];
    self.meanPausesPerMinute = [decoder decodeObjectForKey:@"meanPausesPerMinute"];
    self.meanPauseDuration = [decoder decodeObjectForKey:@"meanPauseDuration"];

    self.totalSyllables = [decoder decodeObjectForKey:@"totalSyllables"];
    self.totalWords = [decoder decodeObjectForKey:@"totalWords"];
    self.totalSentences = [decoder decodeObjectForKey:@"totalSentences"];
    
    self.varRateAsSyllablesPerMinute = [decoder decodeObjectForKey:@"varRateAsSyllablesPerMinute"];
    self.varPitch = [decoder decodeObjectForKey:@"varPitch"];
    self.varVolume = [decoder decodeObjectForKey:@"varVolume"];
    
    self.histRateAsSyllablesPerMinute = [decoder decodeObjectForKey:@"histRateAsSyllablesPerMinute"];
    self.classWordsBySyllables = [decoder decodeObjectForKey:@"classWordsBySyllables"];
    self.classPausesByLength = [decoder decodeObjectForKey:@"classPausesByLength"];
    self.histPitch = [decoder decodeObjectForKey:@"histPitch"];
    self.histVolume = [decoder decodeObjectForKey:@"histVolume"];
    
    self.fleschReadingEase = [decoder decodeObjectForKey:@"fleschReadingEase"];
    self.fleschKincaidGradeEase = [decoder decodeObjectForKey:@"fleschKincaidGradeEase"];
    self.gunningFogIndex = [decoder decodeObjectForKey:@"gunningFogIndex"];
    self.forecastGradeLevel = [decoder decodeObjectForKey:@"forecastGradeLevel"];
    return self;
}

+ (void) copyTalkStatistics:(TalkData *)origin destination:(TalkData*)destination {
    destination.speakerName = [origin.speakerName copy];
    destination.speakerPicture = [origin.speakerPicture copy];
    destination.eventName = [origin.eventName copy];
    destination.date = [origin.date copy];
    
    destination.talkLength = [origin.talkLength copy];
    
    destination.meanRateAsSyllablesPerMinute = [origin.meanRateAsSyllablesPerMinute copy];
    destination.meanRateAsWordsPerMinute = [origin.meanRateAsWordsPerMinute copy];
    destination.meanPitch = [origin.meanPitch copy];
    destination.meanVolume = [origin.meanVolume copy];
    destination.meanPausesPerMinute = [origin.meanPausesPerMinute copy];
    destination.meanPauseDuration = [origin.meanPauseDuration copy];

    destination.totalSyllables = [origin.totalSyllables copy];
    destination.totalWords = [origin.totalWords copy];
    destination.totalSentences = [origin.totalSentences copy];

    destination.varRateAsSyllablesPerMinute = [origin.varRateAsSyllablesPerMinute copy];
    destination.varPitch = [origin.varPitch copy];
    destination.varVolume = [origin.varVolume copy];

    destination.histRateAsSyllablesPerMinute = [origin.histRateAsSyllablesPerMinute copy];
    destination.classWordsBySyllables = [origin.classWordsBySyllables copy];
    destination.classPausesByLength = [origin.classPausesByLength copy];
    destination.histPitch = [origin.histPitch copy];
    destination.histVolume = [origin.histVolume copy];

    destination.fleschReadingEase = [origin.fleschReadingEase copy];
    destination.fleschKincaidGradeEase = [origin.fleschKincaidGradeEase copy];
    destination.gunningFogIndex = [origin.gunningFogIndex copy];
    destination.forecastGradeLevel = [origin.forecastGradeLevel copy];
}

@end

