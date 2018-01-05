//
//  SettingsVC.h
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

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import "EZAudio.h"

/**
 * The SettingsTableViewController class is responsible for the Settings navigation tab.
 * The tab is used to let the user adjust different app settings, such as history size.
 */
@interface SettingsVC : UITableViewController<EZAudioFileDelegate,EZOutputDataSource>

/**
 * Points to the unique appDelegate of the app.
 */
@property (weak, nonatomic) AppDelegate *appDelegate;

/**
 * Text field to enter the maximum size of the history list.
 */
@property (weak, nonatomic) IBOutlet UITextField *histSizeTextField;

@property (weak, nonatomic) IBOutlet UISwitch *debugModeSwitch;

/**
 * Called when the user inputs a new maximum history size.
 * The method checks whether the entered size is within a valid range (1-99)
 * and adjust the size of the history array if required.
 *
 * @param sender  Object of the sender view.
 */
- (IBAction)histSizeEditEndAction:(id)sender;

/**
 * Called when the clear history button is pressed.
 * The method reconfirms the action and upon confirmation
 * removes all entries from the history array.
 *
 * @param sender  Object of the sender view.
 */
- (IBAction)clearHistoryAction:(id)sender;

/**
 * Called when the debug mode is changed.
 *
 * @param sender  Object of the sender view.
 */
- (IBAction)toggleDebugMode:(id)sender;



/**
 A BOOL indicating whether or not we've reached the end of the file
 */
@property (nonatomic,assign) BOOL eof;
/**
 The EZAudioFile representing of the currently selected audio file
 */
@property (nonatomic,strong) EZAudioFile *audioFile;


/**
 * TODO
 *
 * @param sender  Object of the sender view.
 */
- (IBAction)runTestLocalFile:(id)sender;
/**
 * TODO
 *
 * @param sender  Object of the sender view.
 */
//- (IBAction)runTestRemoteFile:(id)sender;
/**
 * TODO
 *
 * @param sender  Object of the sender view.
 */
- (IBAction)runTestBatch:(id)sender;

/**
 * TODO
 *
 * @param sender  Object of the sender view.
 */
- (IBAction)runPrintHistoryData:(id)sender;

@end
