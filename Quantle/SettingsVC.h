//
//  SettingsVC.h
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


/**
 * For test purposes only. Hide these in the final release.
 */
@property (weak, nonatomic) IBOutlet UITableViewCell *runFile;
@property (weak, nonatomic) IBOutlet UITableViewCell *runBatch;
@property (weak, nonatomic) IBOutlet UITableViewCell *runHistory;

@end
