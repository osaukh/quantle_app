//
//  SettingsVC.m
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

#import "SettingsVC.h"
#import "OngoingTalk.h"
#import "ASP.h"

#import "FCAlertView.h"

@interface SettingsVC ()

@end

@implementation SettingsVC
@synthesize audioFile = _audioFile;
@synthesize eof = _eof;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get app delegate
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    // Close keyboard after tap
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
    // Set current history size
    self.histSizeTextField.text = [self.appDelegate.histSize stringValue];
    // Set numerical keyboard for hist size text field
    [self.histSizeTextField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    
    // Set debug switch
    [self.debugModeSwitch setOn:self.appDelegate.debugMode];
    
    // For test purposes only. HIDING UI TEST FIELDS FOR RELEASE
    self.runFile.hidden = YES;
    self.runBatch.hidden = YES;
    self.runHistory.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.histSizeTextField) {
        // Backspace is ok
        if([string length]==0){
            return YES;
        }
    
        // Limit maximum history size to two digits
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if (newLength > 2) {
            return NO;
        }
    
        // Only allow numberic characters as input
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        for (int i = 0; i < [string length]; i++) {
            unichar c = [string characterAtIndex:i];
            if ([myCharSet characterIsMember:c]) {
                return YES;
            }
        }
    
        return NO;
    }
    return YES;
}

- (IBAction)histSizeEditEndAction:(id)sender {
    // No history size, use existing one.
    if ([self.histSizeTextField.text length] == 0) {
        self.histSizeTextField.text = [self.appDelegate.histSize stringValue];
        return;
    }
    
    NSUInteger hSize = [self.histSizeTextField.text integerValue];
    if (hSize == 0) {
        hSize = 1;
        self.histSizeTextField.text = @"1";
    }
    
    // Check current history size and adjust if needed.
    if ([self.appDelegate.historyEntries count] > hSize) {
        // Remove entries
        NSRange r;
        r.location = hSize;
        r.length = [self.appDelegate.historyEntries count] - hSize;
        [self.appDelegate.historyEntries removeObjectsInRange:r];
    }
    
    // Update history size value
    self.appDelegate.histSize = [NSNumber numberWithInt:(int)hSize];
    
    // Update user default
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:hSize forKey:@"histSize"];
    [defaults synchronize];
    
    NSLog(@"History size set to %lu.", (unsigned long)hSize);
}

- (IBAction)clearHistoryAction:(id)sender {
    UIImage* imgMyImage = [UIImage imageNamed:@"about32x32.png"];
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor colorWithRed: 0 green: 0.698 blue: 1 alpha: 1];
    
    [alert showAlertInView:self
                 withTitle:@"Clear History"
              withSubtitle:@"Remove all entries from the history table?"
           withCustomImage:imgMyImage
       withDoneButtonTitle:@"Cancel"
                andButtons:nil];
    
    [alert addButton:@"OK" withActionBlock:^{
        NSLog(@"Removed all objects in the history.");
        [self.appDelegate.historyEntries removeAllObjects];
        [self.appDelegate saveHistory];
    }];
    
    [alert doneActionBlock:^{
        NSLog(@"Canceled history cleaning.");
    }];
}

- (IBAction)toggleDebugMode:(id)sender {
    if( [(UISwitch*)sender isOn] ){
        self.appDelegate.debugMode = TRUE;
    }
    else {
        self.appDelegate.debugMode = FALSE;
    }
    // Update user default
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.appDelegate.debugMode forKey:@"debugMode"];
    [defaults synchronize];
    
    NSLog(@"Debug mode set to %d.", self.appDelegate.debugMode);
}

// TODO: optimize: same function is available in RecordTalkVC
- (NSString *)documentsDirectoryPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

NSString *fileName;
bool noFin;

- (IBAction)runTestLocalFile:(id)sender {
    fileName = @"one/audio1000hzsine3s.wav";
    NSString *wavName = [NSString stringWithFormat:@"%@/%@", [self documentsDirectoryPath], fileName];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'  'HH':'mm':'ss"];
    NSString *dateString = [dateFormatter stringFromDate: [NSDate date]];
    NSLog(@"[%@] Test started at %@", wavName, dateString);

    noFin = true;
    [self readInWAVFile:wavName];
    while (noFin)
        [NSThread sleepForTimeInterval:2.0f];
}

- (IBAction)runTestBatch:(id)sender {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *directoryURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [self documentsDirectoryPath], @"batch"]];
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    
    NSDirectoryEnumerator *enumerator = [fileManager
                                         enumeratorAtURL:directoryURL
                                         includingPropertiesForKeys:keys
                                         options:0
                                         errorHandler:^(NSURL *url, NSError *error) {
                                             // Handle the error.
                                             // Return YES if the enumeration should continue after the error.
                                             return YES;
                                         }];
    
    for (NSURL *url in enumerator) {
        NSError *error;
        NSNumber *isDirectory = nil;
        if (! [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
            // handle error
        }
        else if (! [isDirectory boolValue]) {
            // No error and it’s not a directory; do something with the file
            fileName = [[url absoluteString] substringFromIndex:[@"file:///private" length]];
            NSLog(@"%@", fileName);
            noFin = true;
            [self readInWAVFile:fileName];
            while (noFin)
                [NSThread sleepForTimeInterval:2.0f];
        }
    }
}

#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

- (IBAction)runPrintHistoryData:(id)sender {
    NSLog(@"name,length,syllable_count,word_count,sentence_count,rate_in_syllables,rate_in_words,rate_var,pause_duration,pitch_mean,pitch_var,volume_mean,volume_var,fre,fkgl,gfi,fgl")
    for (TalkData *t in self.appDelegate.historyEntries) {
        NSLog(@"%@,%f,%d,%d,%d,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f", t.speakerName,
              [t.talkLength floatValue],[t.totalSyllables intValue],[t.totalWords intValue],
              [t.totalSentences intValue], [t.meanRateAsSyllablesPerMinute floatValue],
              [t.meanRateAsWordsPerMinute floatValue], [t.varRateAsSyllablesPerMinute floatValue],
              [t.meanPauseDuration floatValue], [t.meanPitch floatValue], [t.varPitch floatValue],
              [t.meanVolume floatValue], [t.varVolume floatValue],
              [t.fleschReadingEase floatValue], [t.fleschKincaidGradeEase floatValue],
              [t.gunningFogIndex floatValue], [t.forecastGradeLevel floatValue]);
    }
}

-(void)readInWAVFile: (NSString*) wavPath {
    [EZOutput sharedOutput].dataSource = self;
    self.audioFile = [EZAudioFile audioFileWithURL:[NSURL fileURLWithPath:wavPath]];
    self.audioFile.delegate = self;
    self.eof = NO;
    
    // Set the client format from the EZAudioFile on the output
    [[EZOutput sharedOutput] setClientFormat:self.audioFile.clientFormat];
    [[EZOutput sharedOutput] startPlayback];
}


#pragma mark - EZAudioFileDelegate
-(void)audioFile:(EZAudioFile *)audioFile
       readAudio:(float **)buffer
  withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    
    ASP_process_buffer((void *) *buffer, bufferSize);
}

#pragma mark - EZOutputDataSource

-(OSStatus)output:(EZOutput *)output shouldFillAudioBufferList:(AudioBufferList *)audioBufferList withNumberOfFrames:(UInt32)frames timestamp:(const AudioTimeStamp *)timestamp {
    if( self.audioFile ){
        UInt32 bufferSize;
        [self.audioFile readFrames:frames
                   audioBufferList:audioBufferList
                        bufferSize:&bufferSize
                               eof:&_eof];
        if( _eof ){
            [[EZOutput sharedOutput] stopPlayback];
            
            // Update all counters
            ASP_print();
            TalkData *td = [OngoingTalk getInstance];
            [OngoingTalk setInstance];
            td.speakerName = fileName;
            td.eventName = @"DEBUG";
            
            // Add a copy of ongoing talk to the history
            TalkData *dest = [TalkData alloc];
            [TalkData copyTalkStatistics:[OngoingTalk getInstance] destination:dest];
            [self.appDelegate.historyEntries insertObject:dest atIndex:0];
            
            // Adjust history size if needed.
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
            
            // Reset counters
            ASP_hard_reset_counters();
            [OngoingTalk resetInstance];
            NSLog(@"Counters reset.");
            noFin = false;
        }
    }
    return noErr;
}

-(AudioStreamBasicDescription)outputHasAudioStreamBasicDescription:(EZOutput *)output {
    return self.audioFile.clientFormat;
}

@end
