//
//  DetailsPausesVC.m
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
    
    // update X pauses
    CGRect frame_X = self.pace_X_pauses.frame;
    frame_X.origin.x= (SCREEN_WIDTH-10) / (0.7-0.3) * (capcut([td.meanPauseDuration doubleValue],0.3,0.7) - 0.3);
    self.pace_X_pauses.frame= frame_X;
    
    [self.tableView reloadData];
    
    NSArray *items = @[[PNPieChartDataItem dataItemWithValue:(int)td.classPausesByLength[0] + (int)td.classPausesByLength[1] color:PNiOSGreenColor description:@"[0.1s-0.4s]"],
                       [PNPieChartDataItem dataItemWithValue:(int)td.classPausesByLength[2] + (int)td.classPausesByLength[3] color:PNDeepGreen description:@"[0.4s-0.1s]"],
                       [PNPieChartDataItem dataItemWithValue:(int)td.classPausesByLength[4] + (int)td.classPausesByLength[5] color:PNBlue description:@">1s"]];
    
    PNPieChart *pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(0.1*SCREEN_WIDTH, 210.0, 0.8*SCREEN_WIDTH, 0.8*SCREEN_WIDTH) items:items];
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
                 withTitle:@"Pauses"
              withSubtitle:@"The more complex the task, the greater is the number of pauses:\nShort: ~0.15 s\nMedium: ~0.50 s\nLong: ~1.50 s\n\nRead speech tends to produce only short and medium pauses, while spontaneous speech shows more frequent use of medium and long pauses. Lengthy pauses are healthy, allow you to take deep breaths, swallow, drink water. It aids your brain by providing more oxygen and gives your audience time to reflect on your words! 😜👌"
           withCustomImage:imgMyImage
       withDoneButtonTitle:nil
                andButtons:nil];
}

@end
