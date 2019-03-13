//
//  StatisticsVC.m
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
    
    // update X FRE
    CGRect frame_X_FRE = self.FRE_X.frame;
    frame_X_FRE.origin.x= (SCREEN_WIDTH-10) / (100-0) * (capcut([td.fleschReadingEase doubleValue],0,100) - 0);
    self.FRE_X.frame= frame_X_FRE;
    // update X FKG
    CGRect frame_X_FKG = self.FKG_X.frame;
    frame_X_FKG.origin.x= (SCREEN_WIDTH-10) / (16-4) * (capcut([td.fleschKincaidGradeEase doubleValue],4,16) - 4);
    self.FKG_X.frame= frame_X_FKG;
    // update X GFI
    CGRect frame_X_GFI = self.GFI_X.frame;
    frame_X_GFI.origin.x= (SCREEN_WIDTH-10) / (16-4) * (capcut([td.gunningFogIndex doubleValue],4,16) - 4);
    self.GFI_X.frame= frame_X_GFI;
    // update X FGL
    CGRect frame_X_FGL = self.FGL_X.frame;
    frame_X_FGL.origin.x= (SCREEN_WIDTH-10) / (16-4) * (capcut([td.forecastGradeLevel doubleValue],4,16) - 4);
    self.FGL_X.frame= frame_X_FGL;
    
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
        [self.appDelegate.historyEntries removeObjectAtIndex:self->td_index];
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
        case 22: // http://en.m.wikipedia.org/wiki/Flesch-Kincaid_Readability_Test
            msgImage = [UIImage imageNamed:@"score_fkg_24x24.png"];
            msgTitle = @"Flesch–Kincaid Grade";
            msgBody = @"Estimates the years of education needed to understand the material. It is used extensively in the field of education and presents a score as a U.S. grade level. The formula correlates 0.91 with comprehension as measured by reading tests.\n\nMake sure your talk is easy to follow! 😜👌";
            break;
        case 24: // http://en.wikipedia.org/wiki/Gunning_fog_index
            msgImage = [UIImage imageNamed:@"score_gfi_24x24.png"];
            msgTitle = @"Gunning Fog Index";
            msgBody = @"Estimates the years of education needed to understand the material. A fog index of 12 requires the level of a U.S. high school senior (around 18 years old). Materials for a wide audience generally need a fog index less than 12. Materials requiring near-universal understanding generally need an index less than 8. The formula correlates 0.91 with comprehension as measured by reading tests and is one of the most reliable. \n\nMake sure your talk is easy to follow! 😜👌";
            break;
        case 26: // http://en.m.wikipedia.org/wiki/Readability#The_FORCAST_formula
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
