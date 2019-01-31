//
//  AppDelegate.h
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
#import <Foundation/Foundation.h>

#define DEFAULT_HIST_SIZE 20
#define DEFAULT_SWITCH TRUE
#define DEFAULT_DEBUGMODE FALSE


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/**
 * History array holds all previous talks computed by the user. Initially it
 * is loaded with some exemplary talks.
 */
@property (nonatomic, strong) NSMutableArray *historyEntries;

/**
 * The maximum number of entries in the history array.
 */
@property (nonatomic, strong) NSNumber *histSize;

/**
 * Indicates whether the app is opened the first time. If yes,
 * the app will display a welcome message.
 */
@property BOOL firstRun;

/**
 * Indicates whether debug mode is enabled. If yes,
 * the app will record talks.
 */
@property BOOL debugMode;

/**
 * Core data funtionality.
 * Object of the core data context.
 */
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

/**
 * Core data funtionality.
 * Object of the core data model.
 */
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

/**
 * Core data funtionality.
 * Object of the core data store coordinator.
 */
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 * Core data funtionality.
 * The method is called to persistently save the context in core data.
 */
- (void)saveContext;

- (void)saveHistory;

/**
 * The method retrieves the URL to the application's document directory.
 *
 * @return URL to the application's document directory.
 */
- (NSURL *)applicationDocumentsDirectory;

/**
 * The method gets all data with the given entity name stored in the
 * application's core data.
 *
 * @param entityName  Name of the entity to retrieve (as defined in the data model).
 * @param context     The context of the core data.
 *
 * @return All data corresponding of the given entity.
 */
- (NSArray *)getCoreData:(NSString *)entityName withContext:(NSManagedObjectContext *)context;

@end

