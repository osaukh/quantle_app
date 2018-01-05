//
//  StatisticsEditDescriptionVC.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "OngoingTalk.h"
#import "StatisticsDetails.h"

@interface StatisticsEditDescriptionVC : UITableViewController<StatisticsDetails,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

/**
 * Points to the unique appDelegate of the app.
 */
@property (weak, nonatomic) AppDelegate *appDelegate;

@property (nonatomic,weak) IBOutlet UITextField *speakerNameTextField;
@property (nonatomic,weak) IBOutlet UIImageView *speakerPicture;
@property (nonatomic,weak) IBOutlet UITextField *eventNameTextField;

/**
 * Set talk data to be shown.
 */
- (void)initData:(int)index talk:(TalkData *) data;

- (IBAction)changeSpeakerName:(id)sender;

- (IBAction)changeEventName:(id)sender;

-(IBAction)takeSpeakerPicture :(id)sender;

- (IBAction) onClickSavePhoto:(id) sender;

@end
