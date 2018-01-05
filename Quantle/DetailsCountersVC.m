//
//  DetailsCountersVC.m
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

#import "DetailsCountersVC.h"
#import "FCAlertView.h"

@interface DetailsCountersVC () {
    TalkData *td;
    int td_index;
};
@end

@implementation DetailsCountersVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get app delegate
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self updateTalkData];
}

- (void)initData:(int)index talk:(TalkData *) data {
    td = data;
    td_index = index;
}
- (void) updateTalkData {
    self.syllablesTotal.text = [NSString stringWithFormat:@"%d",[td.totalSyllables intValue]];
    self.wordsTotal.text = [NSString stringWithFormat:@"%d",[td.totalWords intValue]];
    self.syllablesPerWord.text = [NSString stringWithFormat:@"%.02f",
                                  [td.totalSyllables doubleValue] / [td.totalWords doubleValue]];

    
    [self.tableView reloadData];
    
    NSArray *items = @[[PNPieChartDataItem dataItemWithValue: (int)td.classWordsBySyllables[0] color:PNiOSGreenColor description:@"one"],
                       [PNPieChartDataItem dataItemWithValue: (int)td.classWordsBySyllables[1] color:PNLightGreen description:@"two"],
                       [PNPieChartDataItem dataItemWithValue: (int)td.classWordsBySyllables[2] color:PNDeepGreen description:@"three"],
                       [PNPieChartDataItem dataItemWithValue: (int)td.classWordsBySyllables[3] color:PNBrown description:@"four+"],
                       ];
    
    PNPieChart *pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(0.1*SCREEN_WIDTH, 200.0, 0.8*SCREEN_WIDTH, 0.8*SCREEN_WIDTH) items:items];
    pieChart.descriptionTextColor = [UIColor blackColor];
    pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
    [pieChart strokeChart];
    [self.view addSubview: pieChart];
}

-(IBAction)showInfo:(id)sender {
    // http://sixminutes.dlugan.com/toastmasters-speech-6-vocal-variety/
    UIImage* imgMyImage = [UIImage imageNamed:@"about32x32.png"];
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor colorWithRed: 0 green: 0.698 blue: 1 alpha: 1];
    
    [alert showAlertInView:self
                 withTitle:@"Word Complexity"
              withSubtitle:@"Focus on improving your clarity and lowering the complexity of your language.\n\nSimplify words and simplify your sentences by eliminating unnecessary words. You will become much more understandable! 😜👌"
           withCustomImage:imgMyImage
       withDoneButtonTitle:nil
                andButtons:nil];
}

@end
