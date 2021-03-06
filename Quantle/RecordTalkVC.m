//
//  RecordTalkVC.m
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

#import "RecordTalkVC.h"
#import "HistoryVC.h"
#import "ASP.h"
#import "FCAlertView.h"

#define MICGAIN    20

@interface RecordTalkVC (){
    TPCircularBuffer _circularBuffer;
    TalkData* td;    
}
@end

@implementation RecordTalkVC
@synthesize recorder;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Customizing the audio plot's look
    self.audioPlot.backgroundColor = [UIColor colorWithRed: 0 green: 0.698 blue: 1 alpha: 1];
    self.audioPlot.color           = [UIColor colorWithRed: 1.000 green: 1.000 blue: 1.000 alpha: 1];
    self.audioPlot.plotType = EZPlotTypeRolling;
    self.audioPlot.shouldFill = YES;
    self.audioPlot.shouldMirror = YES;
    self.audioPlot.gain = MICGAIN;
    
    // Initialize the circular buffer
    [EZAudioUtilities circularBuffer:&_circularBuffer withSize:1024];
    
    // Show text if the app is started the first time
    if (self.appDelegate.firstRun) {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Welcome!"
                                     message:@"Quantify talk quality with Quantle! Quantle analyzes mic data and extracts statistics on the speed and complexity of the talk. Quantle estimates speech rate, pitch, volume, use of pauses, and evaluates talk comprehension. Check out the exemplary evaluations stored in the local history."
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {}];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    
    // Start the microphone
    [EZMicrophone sharedMicrophone].delegate = self;
    [[EZMicrophone sharedMicrophone] stopFetchingAudio];
    self.microphoneTextLabel.text = @"OFF";
    
    // Start the output
    [EZOutput sharedOutput].dataSource = self;

    // create and init objects
    td = [OngoingTalk getInstance];
    [self updateUI];
    ASP_hard_reset_counters();
    
    // set all indicators as OK
    self.rateCell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"checkmark"]];
    self.rateVarCell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"checkmark"]];
    self.pitchCell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"checkmark"]];
    self.pitchVarCell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"checkmark"]];
    self.volumeCell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"checkmark"]];
    
    // setup timer for view update
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
}

-(void)toggleMicrophone:(id)sender {
    if( ![(UISwitch*)sender isOn] ){
        [[EZMicrophone sharedMicrophone] stopFetchingAudio];
        self.microphoneTextLabel.text = @"OFF";
        
        if (self.appDelegate.debugMode)
            [self.recorder closeAudioFile];
    }
    else {
        [[EZMicrophone sharedMicrophone] startFetchingAudio];
        self.microphoneTextLabel.text = @"ON";

        if (self.appDelegate.debugMode) {
            self.recorder = [EZRecorder recorderWithURL:[self debugFilePathURL] clientFormat:[[EZMicrophone sharedMicrophone] audioStreamBasicDescription] fileType:EZRecorderFileTypeM4A];
        }

        // initialize TalkData defaults and reset date / time if needed
        self->td = [OngoingTalk getInstance];
        if (self->td.talkLength == 0)
            [OngoingTalk resetTime];
        ASP_soft_reset_counters();
    }
}

-(NSURL*)debugFilePathURL {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd_HHmmSS"];
    NSString *currentLocalDateAsStr = [dateFormatter stringFromDate:[NSDate date]];
    
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@_%@.%@",
                                   [self applicationDocumentsDirectory],
                                   @"QuantleDebug", currentLocalDateAsStr, @"wav"]];
}

-(NSString*)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

// If debug mode: append the AudioBufferList from the microphone callback to a global circular buffer
// Process the newly arrived buffer and extract features
-(void)microphone:(EZMicrophone *)microphone
    hasBufferList:(AudioBufferList *)bufferList
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    
    // if debug write the original to a .wav file
    if( self.appDelegate.debugMode )
        [self.recorder appendDataFromBufferList:bufferList withBufferSize:bufferSize];
    
    // do processing in the background thread
    dispatch_async(dispatch_get_main_queue(), ^{
        // processing
        ASP_process_buffer(bufferList->mBuffers[0].mData, bufferSize);
        
        // update plot
        [self.audioPlot updateBuffer:bufferList->mBuffers[0].mData withBufferSize:bufferSize];
        
        // update basic counters
        self->td.talkLength = @( counters.talk_duration );
        if (counters.talk_duration)
            self->td.meanRateAsSyllablesPerMinute = @(counters.num_syllables / counters.talk_duration);
        [OngoingTalk setRateData];
        [OngoingTalk setPitchData];
        [OngoingTalk setVolumeData];
            
        // update counters in UI
        [self updateUI];
    });
}

-(TPCircularBuffer *)outputShouldUseCircularBuffer:(EZOutput *)output {
    return [EZMicrophone sharedMicrophone].microphoneOn ? &_circularBuffer : nil;
}


-(void)changeSpeakerName:(id)sender {
    NSString *param = self.speakerNameTextField.text;
    [td setSpeakerName:param];
}

-(void)changeEventName:(id)sender {
    NSString *param = self.eventNameTextField.text;
    [td setEventName:param];
}

-(IBAction)stopAndSave:(id)sender {
    // Turn off microphone and stop audio recording
    [self.microphoneSwitch setOn:NO animated:NO];
    [[EZMicrophone sharedMicrophone] stopFetchingAudio];
    self.microphoneTextLabel.text = @"OFF";
    if (self.appDelegate.debugMode)
        [self.recorder closeAudioFile];
    
    // Update all counters
    [OngoingTalk setInstance];
    
    // Add a copy of ongoing talk to the history
    TalkData *dest = [TalkData alloc];
    [TalkData copyTalkStatistics:[OngoingTalk getInstance] destination:dest];
    [self.appDelegate.historyEntries insertObject:dest atIndex:0];
    
    // Adjust history size if needed
    NSUInteger hSize = [self.appDelegate.histSize integerValue];
    if ([self.appDelegate.historyEntries count] > hSize) {
        // Remove entries
        NSRange r;
        r.location = hSize;
        r.length = [self.appDelegate.historyEntries count] - hSize;
        [self.appDelegate.historyEntries removeObjectsInRange:r];
    }
    
    // Save history
    [self.appDelegate saveHistory];
    
    // Clear plot
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.audioPlot clear];
        [self.audioPlot updateBuffer:NULL withBufferSize:0];
    
        // Reset counters
        [self zeroUI];
    });
    
    // Save to history message
    UIImage* imgMyImage = [UIImage imageNamed:@"yestick32x32.png"];
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor colorWithRed: 0 green: 0.698 blue: 1 alpha: 1];
    
    [alert showAlertInView:self
                 withTitle:@"Success"
              withSubtitle:@"Detailed talk evaluation is saved to history."
           withCustomImage:imgMyImage
       withDoneButtonTitle:nil
                andButtons:nil];
    
    alert.autoHideSeconds = 2;
}

-(IBAction)clearAndRestart:(id)sender {
    [[EZMicrophone sharedMicrophone] stopFetchingAudio];
    self.microphoneTextLabel.text = @"OFF";
    [self.microphoneSwitch setOn:NO animated:YES];
    
    if (self.appDelegate.debugMode)
        [self.recorder closeAudioFile];

    // Clear plot
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.audioPlot clear];
        [self.audioPlot updateBuffer:NULL withBufferSize:0];
        
        // Reset counters
        [self zeroUI];
    });
}

/**
 * Zero counters, reset statistics, reset objects
 */
- (void) zeroUI {
    ASP_hard_reset_counters();
    [OngoingTalk resetInstance];

    self.lengthLabel.text = @("0:00:00");
    self.rateLabel.text = @("0.00");
    self.rateVarLabel.text = @("0.00");
    self.pitchLabel.text = @("0.00");
    self.pitchVarLabel.text = @("0.00");
    self.volumeLabel.text = @("0.00");
    
    // reset picture
    [self.speakerPictureButton setImage:[UIImage imageNamed:@"face32x32.png"] forState:UIControlStateNormal];
    [self.speakerPictureButton sizeToFit];
    
    [self updateUI];
    
    // set all indicators as OK
    self.rateCell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"checkmark"]];
    self.rateVarCell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"checkmark"]];
    self.pitchCell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"checkmark"]];
    self.pitchVarCell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"checkmark"]];
    self.volumeCell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"checkmark"]];

    NSLog(@"Counters reset.");
}

- (void) setArrowInfo:(UITableViewCell *)cell value:(double)value lowRed:(double)lr lowYellow:(double)ly upperYellow:(double)uy upperRed:(double)ur {
    if (value >= ly && value <= uy)
        cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"checkmark"]];
    if (value >= lr && value < ly)
        cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"arrow_up_yellow"]];
    if (value < lr)
        cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"arrow_up_red"]];
    if (value > uy && value <= ur)
        cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"arrow_down_yellow"]];
    if (value > ur)
        cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"arrow_down_red"]];
}

- (void)updateUI {
    int lengthInSeconds = (int) (60 * [td.talkLength doubleValue]);
    NSUInteger h = lengthInSeconds / 3600;
    NSUInteger m = (lengthInSeconds / 60) % 60;
    NSUInteger s = lengthInSeconds % 60;
    
    self.lengthLabel.text = [NSString stringWithFormat:@"%u:%02u:%02u", h, m, s];
    self.rateLabel.text = [NSString stringWithFormat:@"%.02f", [td.meanRateAsSyllablesPerMinute doubleValue]];
    self.rateVarLabel.text = [NSString stringWithFormat:@"%.02f", [td.varRateAsSyllablesPerMinute doubleValue]];
    self.pitchLabel.text = [NSString stringWithFormat:@"%.02f", [td.meanPitch doubleValue]];
    self.pitchVarLabel.text = [NSString stringWithFormat:@"%.02f", [td.varPitch doubleValue]];
    self.volumeLabel.text = [NSString stringWithFormat:@"%.02f", [td.meanVolume doubleValue]];
    
    [self setArrowInfo:self.rateCell value:td.meanRateAsSyllablesPerMinute.doubleValue
                lowRed:150 lowYellow:230 upperYellow:270 upperRed:300];
    [self setArrowInfo:self.rateVarCell value:td.varRateAsSyllablesPerMinute.doubleValue
                lowRed:0 lowYellow:20 upperYellow:100 upperRed:100];
    [self setArrowInfo:self.pitchCell value:td.meanPitch.doubleValue
                lowRed:0 lowYellow:0 upperYellow:500 upperRed:500];
    [self setArrowInfo:self.pitchVarCell value:td.varPitch.doubleValue
                lowRed:10 lowYellow:15 upperYellow:100 upperRed:100];
    [self setArrowInfo:self.volumeCell value:td.meanVolume.doubleValue
                lowRed:0 lowYellow:1 upperYellow:20 upperRed:20];
}

-(void)updateTimer {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
}


-(void)dealloc {
    TPCircularBufferClear(&_circularBuffer);
}

-(IBAction)showInstructions:(id)sender {
    UIImage* imgMyImage = [UIImage imageNamed:@"about32x32.png"];
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor colorWithRed: 0 green: 0.698 blue: 1 alpha: 1];
    
    [alert showAlertInView:self
                 withTitle:@"Instructions"
              withSubtitle:@"Quantle works for languages in which syllables are defined by the number of vowels. Place your smartphone close to the speaker. Quantle does NOT work with background music or any other disturbing background sounds. Quantle does NOT work if a talk is interrupted and is very slowly paced."
           withCustomImage:imgMyImage
       withDoneButtonTitle:nil
                andButtons:nil];
}

-(IBAction)takeSpeakerPicture :(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    
    // image picker needs a delegate,
    [imagePickerController setDelegate:self];
    
    // Place image picker on the screen
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    self.speakerPictureButton.backgroundColor=[UIColor clearColor];
    [self.speakerPictureButton.layer setCornerRadius:8.0f];
    [self.speakerPictureButton.layer setMasksToBounds:YES];
    [self.speakerPictureButton setImage:image forState:UIControlStateNormal];
    [self.speakerPictureButton sizeToFit];
    
    td.speakerPicture = UIImagePNGRepresentation(image);
}

#pragma mark - EZOutputDataSource

-(OSStatus)output:(EZOutput *)output shouldFillAudioBufferList:(AudioBufferList *)audioBufferList withNumberOfFrames:(UInt32)frames timestamp:(const AudioTimeStamp *)timestamp {
    return noErr;
}

@end
