//
//  StatisticsVC.h
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
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "TalkData.h"
#import "StatisticsDetails.h"

#import "PNChartDelegate.h"
#import "PNChart.h"

@interface StatisticsVC : UITableViewController<PNChartDelegate, StatisticsDetails>

/**
 * Points to the unique appDelegate of the app.
 */
@property (weak, nonatomic) AppDelegate *appDelegate;

@property (nonatomic,weak) IBOutlet UILabel *speakerName;
@property (nonatomic,weak) IBOutlet UIImageView *speakerPicture;
@property (nonatomic,weak) IBOutlet UILabel *event;

@property (nonatomic,weak) IBOutlet UILabel *length;

@property (nonatomic,weak) IBOutlet UILabel *words;
@property (nonatomic,weak) IBOutlet UILabel *pauses;
@property (nonatomic,weak) IBOutlet UILabel *meanRate;
@property (nonatomic,weak) IBOutlet UILabel *meanPitch;
@property (nonatomic,weak) IBOutlet UILabel *meanVolume;

@property (nonatomic,weak) IBOutlet UILabel *fleschReadingEase;
@property (nonatomic,weak) IBOutlet UILabel *fleschKincaidRate;
@property (nonatomic,weak) IBOutlet UILabel *gunningFogIndex;
@property (nonatomic,weak) IBOutlet UILabel *forecastGradeLevel;

/**
 * Set talk data to be shown.
 */
- (void)initData:(int)index talk:(TalkData *) data;

-(void)updateFromHistory;

-(IBAction)deleteFromHistory:(id)sender;

@end
