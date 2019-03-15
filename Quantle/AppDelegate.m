//
//  AppDelegate.m
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

#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import <AVFoundation/AVFoundation.h>
#import "OngoingTalk.h"

@implementation AppDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Remember to configure your audio session
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = NULL;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
    if( err ){
        NSLog(@"There was an error creating the audio session");
    }
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:NULL];
    if( err ){
        NSLog(@"There was an error sending the audio to the speakers");
    }
        
    NSDictionary *userDefaultsDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInt:DEFAULT_HIST_SIZE], @"histSize",
                                          [NSNumber numberWithBool:DEFAULT_SWITCH], @"firstRun",
                                          [NSNumber numberWithBool:DEFAULT_DEBUGMODE], @"debugMode",
                                          [NSNumber numberWithInt:DEFAULT_APP_RANDOM], @"appRandom",
                                          nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDefaults];
    
    // Load user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Load history size from the stored settings
    NSInteger defHistSize = [defaults integerForKey:@"histSize"];
    self.histSize = [NSNumber numberWithInt:(int)defHistSize];
    
    // Create empty history list
    self.historyEntries = [NSMutableArray arrayWithCapacity:[self.histSize integerValue]];
    
    // Load app random
    self.appRandom = (uint32_t) [defaults integerForKey:@"appRandom"];
    
    // If first run, show a message to user and set the standard data base
    if ([defaults boolForKey:@"firstRun"]) {
        NSLog(@"firstRun");
        // Generate app instance unique number
        self.appRandom = arc4random();
        [defaults setInteger:self.appRandom forKey:@"appRandom"];
        [defaults setBool:FALSE forKey:@"firstRun"];
        [defaults synchronize];
        
        self.firstRun = TRUE;
        
        // Set default core data sqlite DB to standard DB
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"QuantleCoreDataImport.sqlite"];
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"QuantleCoreDataImport" ofType:@"sqlite"]];
        NSError* err = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
            NSLog(@"Error: Could not copy preloaded data");
        }
        
        [self addSkipBackupAttributeToItemAtURL:storeURL];
    } else {
        self.firstRun = FALSE;
    }

    self.debugMode = [defaults boolForKey:@"debugMode"];
    
    // Load history core data
    NSManagedObjectContext *context = [self managedObjectContext];
    NSArray *fetchedObjects = [self getCoreData:@"HistoryTalks" withContext:context];
    NSLog(@"Fetched %lu objects from the history.", (unsigned long)[fetchedObjects count]);
    for (NSManagedObject *obj in fetchedObjects) {
        NSData *data = [obj valueForKey:@"talk"];
        TalkData *talk = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [self.historyEntries addObject:talk];
    }
    
    // Sort history array
    NSArray *sortedArray;
    sortedArray = [self.historyEntries sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [(TalkData *)a date];
        NSDate *second = [(TalkData *)b date];
        return [second compare:first];
    }];
    self.historyEntries = [sortedArray mutableCopy];

    // Adjust history size if needed.
    NSUInteger hSize = [self.histSize integerValue];
    if ([self.historyEntries count] > hSize) {
        // Remove entries
        NSRange r;
        r.location = hSize;
        r.length = [self.historyEntries count] - hSize;
        [self.historyEntries removeObjectsInRange:r];
    }
    
    // don't turn off screen
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    return YES;
}

// Returns the URL to the application's document directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)saveHistory {
    // Get context.
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // Fetch all entries in core data HistoryRoutes and delete them.
    NSArray *fetchedObjects = [self getCoreData:@"HistoryTalks" withContext:context];
    for (NSManagedObject *obj in fetchedObjects) {
        [context deleteObject:obj];
    }
    
    // Store history talks in core data
    for (TalkData *t in self.historyEntries) {
        NSManagedObject *dataRecord = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryTalks" inManagedObjectContext:context];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:t];
        [dataRecord setValue:data forKey:@"talk"];
    }

//    // Store appRandom
//    NSManagedObject *dataRecord = [NSEntityDescription insertNewObjectForEntityForName:@"AppRandom" inManagedObjectContext:context];
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[NSNumber numberWithInt:self.appRandom]];
//    [dataRecord setValue:data forKey:@"AppRandom"];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Error:%@", error);
    }
    
    NSLog(@"History saved.");
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"QuantleCoreDataImport" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"QuantleCoreDataImport.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self addSkipBackupAttributeToItemAtURL:storeURL];
    
    return _persistentStoreCoordinator;
}

// Exclude database from being backed up in icloude
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self saveHistory];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //start animation now that we're in the foreground
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSArray *)getCoreData:(NSString *)entityName withContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    return fetchedObjects;
}

@end
