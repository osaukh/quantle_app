//
//  StatisticsEditDescriptionVC.m
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
