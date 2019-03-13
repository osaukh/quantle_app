//
//  DetailsRateVC.m
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

#import "DetailsRateVC.h"
#import "FCAlertView.h"

@interface DetailsRateVC () {
    TalkData *td;
    int td_index;
};
@end

@implementation DetailsRateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get app delegate
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Rotate Y axis in the chart
    [self.chartYaxisUILabel setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
    
    [self updateTalkData];
}

- (void)initData:(int)index talk:(TalkData *) data {
    td = data;
    td_index = index;
}

- (void) updateTalkData {
    self.pace_spm.text = [NSString stringWithFormat:@"%.02f", [td.meanRateAsSyllablesPerMinute doubleValue]];
    self.pace_wpm.text = [NSString stringWithFormat:@"%.02f", [td.meanRateAsWordsPerMinute doubleValue]];
    self.pace_var.text = [NSString stringWithFormat:@"%.02f", [td.varRateAsSyllablesPerMinute doubleValue]];

    // update X spm
    CGRect frame_X_spm = self.pace_X_spm.frame;
    frame_X_spm.origin.x= (SCREEN_WIDTH-10) / (350-100) * (fit_to_interval([td.meanRateAsSyllablesPerMinute doubleValue],100,350) - 100);
    self.pace_X_spm.frame= frame_X_spm;
    // update X wpm
    CGRect frame_X_wpm = self.pace_X_wpm.frame;
    frame_X_wpm.origin.x= (SCREEN_WIDTH-10) / (220-100) * (fit_to_interval([td.meanRateAsWordsPerMinute doubleValue],100,220) - 100);
    self.pace_X_wpm.frame= frame_X_wpm;
    // update X var
    CGRect frame_X_var = self.pace_X_var.frame;
    frame_X_var.origin.x= (SCREEN_WIDTH-10) / (40-15) * (fit_to_interval([td.varRateAsSyllablesPerMinute doubleValue],15,40) - 15);
    self.pace_X_var.frame= frame_X_var;

    [self.tableView reloadData];
    
    // prepare xlabels
    NSMutableArray *histxlabels = [NSMutableArray array];
    for (int i=0; i<[td.histRateAsSyllablesPerMinute count]; i++)
        [histxlabels addObject:@( (i*30) )];
    
    // BarChart: speech rate (syllables per minute)
    PNBarChart * chart = [[PNBarChart alloc] initWithFrame:
                          CGRectMake(5, 240.0, SCREEN_WIDTH, SCREEN_WIDTH * 0.8)];
    chart.backgroundColor = [UIColor clearColor];
    chart.yLabelFormatter = ^(CGFloat yValue){
        CGFloat yValueParsed = yValue;
        NSString * labelText = [NSString stringWithFormat:@"%1.f",yValueParsed];
        return labelText;
    };
    chart.isShowNumbers = NO;
    chart.xLabelSkip = 2;
    [chart setXLabels:histxlabels];
    chart.rotateForXAxisText = false ;
    [chart setYValues:td.histRateAsSyllablesPerMinute];
    [chart setStrokeColor:PNDeepGreen];
    chart.barBackgroundColor = PNGrey;
    [chart strokeChart];
    chart.delegate = self;
    [self.view addSubview:chart];
}

-(IBAction)showInfo:(id)sender {
    // http://sixminutes.dlugan.com/speaking-rate/
    UIImage* imgMyImage = [UIImage imageNamed:@"about32x32.png"];
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor colorWithRed: 0 green: 0.698 blue: 1 alpha: 1];
    
    [alert showAlertInView:self
                 withTitle:@"Pace"
              withSubtitle:@"Pace is calculated in syllables per minute (spm). Longer sentences and more complex speech content means more pauses are necessary.\n\nAverage pace of a public speaker is 150 spm - 350 spm. If your pace is 200 spm - 270 spm you are fine.\n\nDon’t deliver sentence after sentence at the same exact rate! Varying your pace adds life to your vocal delivery, allowing you to convey both meaning and emotional content. 😜👌"
           withCustomImage:imgMyImage
       withDoneButtonTitle:nil
                andButtons:nil];
}

@end
