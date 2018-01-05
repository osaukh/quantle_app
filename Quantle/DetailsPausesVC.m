//
//  DetailsPausesVC.m
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

#import "DetailsPausesVC.h"
#import "FCAlertView.h"

@interface DetailsPausesVC () {
    TalkData *td;
    int td_index;
};
@end

@implementation DetailsPausesVC

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
    self.pausesDuration.text = [NSString stringWithFormat:@"%.02f", [td.meanPauseDuration doubleValue]];
    self.pausesSentences.text = [NSString stringWithFormat:@"%d", [td.totalSentences intValue]];
    
    [self.tableView reloadData];
    
    NSArray *items = @[[PNPieChartDataItem dataItemWithValue:(int)td.classPausesByLength[0] + (int)td.classPausesByLength[1] color:PNiOSGreenColor description:@"[0.1s-0.4s]"],
                       [PNPieChartDataItem dataItemWithValue:(int)td.classPausesByLength[2] + (int)td.classPausesByLength[3] color:PNDeepGreen description:@"[0.4s-0.1s]"],
                       [PNPieChartDataItem dataItemWithValue:(int)td.classPausesByLength[4] + (int)td.classPausesByLength[5] color:PNBlue description:@">1s"]];
    
    PNPieChart *pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(0.1*SCREEN_WIDTH, 170.0, 0.8*SCREEN_WIDTH, 0.8*SCREEN_WIDTH) items:items];
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
                 withTitle:@"Pauses & Talk Complexity"
              withSubtitle:@"The more complex the task, the greater is the number of pauses:\nShort: ~0.15 s\nMedium: ~0.50 s\nLong: ~1.50 s\n\nRead speech tends to produce only short and medium pauses, while spontaneous speech shows more frequent use of medium and long pauses. Lengthy pauses are healthy, allow you to take deep breaths, swallow, drink water. It aids your brain by providing more oxygen and gives your audience time to reflect on your words! 😜👌"
           withCustomImage:imgMyImage
       withDoneButtonTitle:nil
                andButtons:nil];
}

@end
