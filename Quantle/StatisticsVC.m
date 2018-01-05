//
//  StatisticsVC.m
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

#import "StatisticsVC.h"
#import "StatisticsEditDescriptionVC.h"
#import "RecordTalkVC.h"

#import "FCAlertView.h"

@interface StatisticsVC () {
    TalkData *td;
    int td_index;
    int td_index_max;
};
@end

@implementation StatisticsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get app delegate
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    td_index_max = (int)[self.appDelegate.historyEntries count];
    
    [self updateFromHistory];
}

- (void)initData:(int)index talk:(TalkData *) data {
    td = data;
    td_index = index;
}
- (void)updateFromHistory {
    self.speakerName.text = td.speakerName;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'  'HH':'mm':'ss"];
    NSString *dateString = [dateFormatter stringFromDate: td.date];
    self.event.text = [NSString stringWithFormat:@"%@, %@",
                            td.eventName, dateString];
    
    // add picture
    self.speakerPicture.backgroundColor=[UIColor clearColor];
    [self.speakerPicture.layer setCornerRadius:8.0f];
    [self.speakerPicture.layer setMasksToBounds:YES];
    [self.speakerPicture setImage:[UIImage imageWithData:td.speakerPicture]];
    
    self.length.text = [NSString stringWithFormat:@"%.02f min", [td.talkLength doubleValue]];
    self.words.text = [NSString stringWithFormat:@"%li words", (long)[td.totalWords integerValue]];
    self.meanRate.text = [NSString stringWithFormat:@"%.02f spm", [td.meanRateAsSyllablesPerMinute doubleValue]];
    self.pauses.text = [NSString stringWithFormat:@"%.02f s", [td.meanPauseDuration doubleValue]];
    self.meanPitch.text = [NSString stringWithFormat:@"%.02f Hz", [td.meanPitch doubleValue]];
    self.meanVolume.text = [NSString stringWithFormat:@"%.02f level", [td.meanVolume doubleValue]];
    
    self.fleschReadingEase.text = [NSString stringWithFormat:@"%.02f", [td.fleschReadingEase doubleValue]];
    self.fleschKincaidRate.text = [NSString stringWithFormat:@"%.02f", [td.fleschKincaidGradeEase doubleValue]];
    self.gunningFogIndex.text = [NSString stringWithFormat:@"%.02f", [td.gunningFogIndex doubleValue]];
    self.forecastGradeLevel.text = [NSString stringWithFormat:@"%.02f", [td.forecastGradeLevel doubleValue]];
    
    [self.tableView reloadData];
}

-(IBAction)deleteFromHistory:(id)sender {
    NSLog(@"deleteFromHistory");
    
    UIImage* imgMyImage = [UIImage imageNamed:@"about32x32.png"];
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor colorWithRed: 0 green: 0.698 blue: 1 alpha: 1];
    
    [alert showAlertInView:self
                 withTitle:@"Delete Talk"
              withSubtitle:@"Remove talk from the history table?"
           withCustomImage:imgMyImage
       withDoneButtonTitle:@"Cancel"
                andButtons:nil];
    
    [alert addButton:@"OK" withActionBlock:^{
        NSLog(@"Remove entry from history");
        [self.appDelegate.historyEntries removeObjectAtIndex:td_index];
        [self.navigationController popViewControllerAnimated:YES];
        [self.appDelegate saveHistory];
    }];
    
    [alert doneActionBlock:^{
        NSLog(@"Cancel remove entry");
    }];    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    NSString *msgTitle;
    NSString *msgBody;
    UIImage *msgImage;
    
    switch (indexPath.section * 10 + indexPath.row) {
        case 20: // http://en.m.wikipedia.org/wiki/Flesch_reading_ease#
            msgImage = [UIImage imageNamed:@"score_fre_24x24.png"];
            msgTitle = @"Flesch Reading Ease";
            msgBody = @"90-100: easily understood by an average 11-year-old\n60-70: easily understood by 13- to 15-year-old\n0-30: best understood by university graduates.\n\nTexts in popular newspapers have score of 50-65. The U.S. Department of Defense uses this test as the standard test of readability for its documents. The formula correlates 0.70 with comprehension as measured by reading tests.\n\nMake sure your talk is easy to follow! 😜👌";
            break;
        case 21: // http://en.m.wikipedia.org/wiki/Flesch-Kincaid_Readability_Test
            msgImage = [UIImage imageNamed:@"score_fkg_24x24.png"];
            msgTitle = @"Flesch–Kincaid Grade";
            msgBody = @"Estimates the years of education needed to understand the material. It is used extensively in the field of education and presents a score as a U.S. grade level. The formula correlates 0.91 with comprehension as measured by reading tests.\n\nMake sure your talk is easy to follow! 😜👌";
            break;
        case 22: // http://en.wikipedia.org/wiki/Gunning_fog_index
            msgImage = [UIImage imageNamed:@"score_gfi_24x24.png"];
            msgTitle = @"Gunning Fog Index";
            msgBody = @"Estimates the years of education needed to understand the material. A fog index of 12 requires the level of a U.S. high school senior (around 18 years old). Materials for a wide audience generally need a fog index less than 12. Materials requiring near-universal understanding generally need an index less than 8. The formula correlates 0.91 with comprehension as measured by reading tests and is one of the most reliable. \n\nMake sure your talk is easy to follow! 😜👌";
            break;
        case 23: // http://en.m.wikipedia.org/wiki/Readability#The_FORCAST_formula
            msgImage = [UIImage imageNamed:@"score_fgl_24x24.png"];
            msgTitle = @"Forecast Grade Level";
            msgBody = @"Estimates the years of education needed to understand the material. The formula was produced for the U.S. military and unlike most other formulas it is useful for materials without complete sentences. It correlates 0.66 with comprehension as measured by reading tests. \n\nMake sure your talk is easy to follow! 😜👌";
            break;
    }
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor colorWithRed: 0 green: 0.698 blue: 1 alpha: 1];
    
    [alert showAlertInView:self
                 withTitle:msgTitle
              withSubtitle:msgBody
           withCustomImage:msgImage
       withDoneButtonTitle:nil
                andButtons:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [segue.destinationViewController initData:td_index talk:td];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // refresh talk data
    if (td_index_max == (int)[self.appDelegate.historyEntries count])
        td = (self.appDelegate.historyEntries)[td_index];
    else
        td = (self.appDelegate.historyEntries)[0];
    [self updateFromHistory];
}

@end