//
//  WSUTwitterClientAppDelegate.h
//  WSUTwitterClient
//
//  Created by Skylar Hiebert on 3/13/12.
//  Copyright (c) 2012 skylarhiebert.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSUTwitterClientAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSString *lastRefresh;
@property (strong, nonatomic) NSMutableArray *tweets;
@property (strong, nonatomic) NSMutableData *getTweetsData;
@property (strong, nonatomic) NSMutableData *sendTweetsData;
@property (strong, nonatomic) NSURLConnection *getTweetsConnection;
@property (strong, nonatomic) NSURLConnection *sendTweetsConnection;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)refreshTweetsWithURL:(NSURL *)url;

@end
