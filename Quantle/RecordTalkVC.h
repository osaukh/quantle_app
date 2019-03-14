//
//  RecordTalkVC.h
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
#import "EZAudio.h"
#import "OngoingTalk.h"
#import "AppDelegate.h"


@interface RecordTalkVC : UITableViewController <EZMicrophoneDelegate, EZOutputDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

/**
 * Points to the unique appDelegate of the app.
 */
@property (weak, nonatomic) AppDelegate *appDelegate;
/**
 * The OpenGL based audio plot
 */
@property (nonatomic,weak) IBOutlet EZAudioPlotGL *audioPlot;
/**
 * Talk recorder to store talks to .wav files if debug is enabled
 */
@property (nonatomic,strong) EZRecorder *recorder;

@property (nonatomic,weak) IBOutlet UILabel *microphoneTextLabel;
@property (nonatomic,weak) IBOutlet UISwitch *microphoneSwitch;

@property (nonatomic,weak) IBOutlet UITextField *speakerNameTextField;
@property (nonatomic,weak) IBOutlet UIButton *speakerPictureButton;
@property (nonatomic,weak) IBOutlet UITextField *eventNameTextField;

@property (nonatomic,weak) IBOutlet UILabel *lengthLabel;
@property (nonatomic,weak) IBOutlet UILabel *rateLabel;
@property (nonatomic,weak) IBOutlet UILabel *rateVarLabel;
@property (nonatomic,weak) IBOutlet UILabel *pitchLabel;
@property (nonatomic,weak) IBOutlet UILabel *pitchVarLabel;
@property (nonatomic,weak) IBOutlet UILabel *volumeLabel;

@property (nonatomic,weak) IBOutlet UITableViewCell *rateCell;
@property (nonatomic,weak) IBOutlet UITableViewCell *rateVarCell;
@property (nonatomic,weak) IBOutlet UITableViewCell *pitchCell;
@property (nonatomic,weak) IBOutlet UITableViewCell *pitchVarCell;
@property (nonatomic,weak) IBOutlet UITableViewCell *volumeCell;

/**
 Sets real-time performance indication arrows.
 */
-(void) setArrowInfo:(UITableViewCell *)cell value:(double)value lowRed:(double)lr lowYellow:(double)ly upperYellow:(double)uy upperRed:(double)ur;

/**
 Toggles the microphone on and off. When the microphone is on it will send its delegate (aka this view controller) the audio data in various ways (check out the EZMicrophoneDelegate documentation for more details).
 */
-(IBAction)toggleMicrophone:(id)sender;

-(IBAction)changeSpeakerName:(id)sender;

-(IBAction)takeSpeakerPicture :(id)sender;

-(IBAction)changeEventName:(id)sender;

-(IBAction)stopAndSave:(id)sender;

-(IBAction)clearAndRestart:(id)sender;

-(IBAction)showInstructions:(id)sender;
    
@end
