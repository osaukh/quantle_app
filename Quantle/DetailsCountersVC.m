//
//  DetailsCountersVC.m
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
