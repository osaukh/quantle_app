//
//  StatisticsEditDescriptionVC.m
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

#import "StatisticsEditDescriptionVC.h"

@interface StatisticsEditDescriptionVC () {
    TalkData *td;
    int td_index;
};
@end

@implementation StatisticsEditDescriptionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get app delegate
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.speakerPicture.backgroundColor=[UIColor clearColor];
    [self.speakerPicture.layer setMasksToBounds:NO];
    self.speakerPicture.contentMode = UIViewContentModeScaleAspectFit;
    [self.speakerPicture setImage:[UIImage imageWithData:td.speakerPicture]];
    
    [self updateTalkData];
}

- (void)initData:(int)index talk:(TalkData *) data {
    td = data;
    td_index = index;
}

- (void) updateTalkData {
    self.speakerNameTextField.text = td.speakerName;
    self.eventNameTextField.text = td.eventName;
    [self.tableView reloadData];
}

-(void)changeSpeakerName:(id)sender {
    NSString *param = self.speakerNameTextField.text;
    [td setSpeakerName:param];
    [self saveChanges];
}

-(void)changeEventName:(id)sender {
    NSString *param = self.eventNameTextField.text;
    [td setEventName:param];
    [self saveChanges];
}

-(void)saveChanges {
    TalkData *dest = [TalkData alloc];
    [TalkData copyTalkStatistics:td destination:dest];
    [self.appDelegate.historyEntries replaceObjectAtIndex:td_index withObject:dest];
    
    // Get context.
    NSManagedObjectContext *context = [self.appDelegate managedObjectContext];
    
    // Fetch all entries in core data HistoryTalks and delete them.
    NSArray *fetchedObjects = [self.appDelegate getCoreData:@"HistoryTalks" withContext:context];
    for (NSManagedObject *obj in fetchedObjects) {
        [context deleteObject:obj];
    }
    
    // Store history routes in core data
    for (TalkData *t in self.appDelegate.historyEntries) {
        NSManagedObject *dataRecord = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryTalks" inManagedObjectContext:context];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:t];
        [dataRecord setValue:data forKey:@"talk"];
    }
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Error:%@", error);
    }
    
    NSLog(@"Talk updated.");
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
    td.speakerPicture = UIImagePNGRepresentation(image);
    
    
    self.speakerPicture.backgroundColor=[UIColor clearColor];
    [self.speakerPicture.layer setMasksToBounds:NO];
    self.speakerPicture.contentMode = UIViewContentModeScaleAspectFit;
    [self.speakerPicture setImage:[UIImage imageWithData:td.speakerPicture]];
}

- (IBAction)onClickSavePhoto:(id)sender{
    
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:td.speakerPicture], nil, nil, nil);
}

@end
