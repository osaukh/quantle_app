//
//  AppDelegate.h
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

