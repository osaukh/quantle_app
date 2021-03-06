//
//  DetailsVolumeVC.m
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

#import "DetailsVolumeVC.h"
#import "FCAlertView.h"

@interface DetailsVolumeVC () {
    TalkData *td;
    int td_index;
};
@end

@implementation DetailsVolumeVC

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
    self.volumeMean.text = [NSString stringWithFormat:@"%.02f",[td.meanVolume doubleValue]];
    self.volumeVariability.text = [NSString stringWithFormat:@"%.02f", [td.varVolume doubleValue]];
    
    [self.tableView reloadData];
    
    // prepare xlabels
    NSMutableArray *histxlabels = [NSMutableArray array];
    for (int i=0; i<[td.histVolume count]; i++)
        [histxlabels addObject:@( i )];
    
    // BarChart: speech rate (syllables per minute)
    PNBarChart * chart = [[PNBarChart alloc] initWithFrame:CGRectMake(5, 140.0, SCREEN_WIDTH, SCREEN_WIDTH*0.8)];
    chart.backgroundColor = [UIColor clearColor];
//    chart.yLabelFormatter = ^(CGFloat yValue){
//        CGFloat yValueParsed = yValue;
//        NSString * labelText = [NSString stringWithFormat:@"%1.f",yValueParsed];
//        return labelText;
//    };
    chart.isShowNumbers = NO;
    chart.xLabelSkip = 2;
    [chart setXLabels:histxlabels];
    chart.rotateForXAxisText = false;
    [chart setYValues:td.histVolume];
    [chart setStrokeColor:PNDeepGreen];
    chart.barBackgroundColor = PNGrey;
    [chart strokeChart];
    chart.delegate = self;
    [self.view addSubview:chart];
}

-(IBAction)showInfo:(id)sender {
    // http://sixminutes.dlugan.com/volume-public-speaker/
    UIImage* imgMyImage = [UIImage imageNamed:@"about32x32.png"];
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor colorWithRed: 0 green: 0.698 blue: 1 alpha: 1];
    
    [alert showAlertInView:self
                 withTitle:@"Power"
              withSubtitle:@"Be comfortably heard by everyone in the audience: minimize noise distractions; minimize the distance to the audience; raise your volume to reach the person in the back row. \n\n Vary your volume strategically throughout the talk. Just as gestures and body movement create visual interest, varying your volume creates vocal interest! 😜👌 \n\n Note: Power and power variability estimated by Quantle do NOT indicate how well the audience hears you."
           withCustomImage:imgMyImage
       withDoneButtonTitle:nil
                andButtons:nil];
}

@end
