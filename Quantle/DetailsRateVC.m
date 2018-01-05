//
//  DetailsRateVC.m
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
    self.rateInSyllables.text = [NSString stringWithFormat:@"%.02f",[td.meanRateAsSyllablesPerMinute doubleValue]];
    self.rateInWords.text = [NSString stringWithFormat:@"%.02f", [td.meanRateAsWordsPerMinute doubleValue]];
    self.rateVariability.text = [NSString stringWithFormat:@"%.02f", [td.varRateAsSyllablesPerMinute doubleValue]];
    
    [self.tableView reloadData];
    
    // prepare xlabels
    NSMutableArray *histxlabels = [NSMutableArray array];
    for (int i=0; i<[td.histRateAsSyllablesPerMinute count]; i++)
        [histxlabels addObject:@( (i*30) )];
    
    // BarChart: speech rate (syllables per minute)
    PNBarChart * chart = [[PNBarChart alloc] initWithFrame:CGRectMake(5, 160.0, SCREEN_WIDTH, SCREEN_WIDTH)];
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
    [chart setStrokeColor:PNLightGreen];
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
                 withTitle:@"Speech Rate"
              withSubtitle:@"Average speech rate is calculated in syllables per minute (spm). Longer sentences and more complex speech content means more pauses are necessary.\n\nAverage speech rate of a public speaker is 150 spm - 350 spm. If your speech rate is 200 spm - 270 spm you are fine.\n\nDon’t deliver sentence after sentence at the same exact rate! Varying your speech rate adds life to your vocal delivery, allowing you to convey both meaning and emotional content. 😜👌"
           withCustomImage:imgMyImage
       withDoneButtonTitle:nil
                andButtons:nil];
}

@end
