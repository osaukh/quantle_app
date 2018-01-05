//
//  RecordTalkVC.h
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
@property (nonatomic,weak) IBOutlet UILabel *pitchLabel;
@property (nonatomic,weak) IBOutlet UILabel *volumeLabel;

/**
 Toggles the microphone on and off. When the microphone is on it will send its delegate (aka this view controller) the audio data in various ways (check out the EZMicrophoneDelegate documentation for more details);
 */
-(IBAction)toggleMicrophone:(id)sender;

-(IBAction)changeSpeakerName:(id)sender;

-(IBAction)takeSpeakerPicture :(id)sender;

-(IBAction)changeEventName:(id)sender;

-(IBAction)stopAndSave:(id)sender;

-(IBAction)clearAndRestart:(id)sender;

-(IBAction)showInstructions:(id)sender;
    
@end
