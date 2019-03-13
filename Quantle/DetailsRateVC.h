//
//  DetailsRateVC.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "TalkData.h"
#import "Utils.h"
#import "StatisticsDetails.h"

#import "PNChartDelegate.h"
#import "PNChart.h"

@interface DetailsRateVC : UITableViewController<PNChartDelegate,StatisticsDetails>
/**
 * Points to the unique appDelegate of the app.
 */
@property (weak, nonatomic) AppDelegate *appDelegate;

@property (nonatomic,weak) IBOutlet UILabel *pace_X_spm;
@property (nonatomic,weak) IBOutlet UILabel *pace_X_wpm;
@property (nonatomic,weak) IBOutlet UILabel *pace_X_var;

@property (nonatomic,weak) IBOutlet UILabel *pace_spm;
@property (nonatomic,weak) IBOutlet UILabel *pace_wpm;
@property (nonatomic,weak) IBOutlet UILabel *pace_var;

@property (nonatomic,weak) IBOutlet UILabel *chartYaxisUILabel;
/**
 * Set talk data to be shown.
 */
- (void)initData:(int)index talk:(TalkData *) data;

-(IBAction)showInfo:(id)sender;

@end
