//
//  WSUTwitterClientAppDelegate.m
//  WSUTwitterClient
//
//  Created by Skylar Hiebert on 3/13/12.
//  Copyright (c) 2012 skylarhiebert.com. All rights reserved.
//

#import "WSUTwitterClientAppDelegate.h"
#import "TweetsTableViewController.h"
#import "Tweet.h"

@implementation WSUTwitterClientAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize lastRefresh = _lastRefresh;
@synthesize tweets = _tweets;
@synthesize getTweetsData = _getTweetsData;
@synthesize sendTweetsData = _sendTweetsData;
@synthesize getTweetsConnection = _getTweetsConnection;
@synthesize sendTweetsConnection = _sendTweetsConnection;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    TweetsTableViewController *viewController = [[TweetsTableViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = navController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSLog(@"saveContext");
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Connection Callbacks

- (void)refreshTweetsWithURL:(NSURL *)url {
    NSLog(@"refreshTweetsWithURL:%@", url);
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    self.getTweetsConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (self.getTweetsConnection) {
        self.getTweetsData = [[NSMutableData alloc] init]; 
    } else {
        NSLog(@"Error in refreshTweetsWithURL:%@", url);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"connection:connection didReceiveResponse:");
    if (connection == self.getTweetsConnection) {
        [self.getTweetsData setLength:0];
    } else if (connection == self.sendTweetsConnection) {
        [self.sendTweetsData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"connection:connection didReceiveData:");
    if (connection == self.getTweetsConnection) {
        [self.getTweetsData appendData:data];
    } else if (connection == self.sendTweetsConnection) {
        [self.sendTweetsData appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"connection:connection didFailWithError:");
    if (connection == self.getTweetsConnection) {
        self.getTweetsData = nil;
        NSLog(@"getTweets Failed with error: %@", error);
    } else if (connection == self.sendTweetsConnection) {
        self.sendTweetsData = nil;
        NSLog(@"sendTweets Failed with error: %@", error);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading:");
    if (connection == self.getTweetsConnection) {
        NSError *error;
        NSArray *newTweets = [NSPropertyListSerialization propertyListWithData:self.getTweetsData options:NSPropertyListMutableContainersAndLeaves format:NULL error:&error];
        
        if ([newTweets count] > 0) {   
            NSArray *sortedArray;
            sortedArray = [newTweets sortedArrayUsingComparator:^(id a, id b) {
                NSString *first = [(Tweet *)a tstamp];
                NSString *second = [(Tweet *)b tstamp];
                return [first compare:second];
            }];
            
            // Convert from array of dictionaries to array of Tweets
            // Add to persistant store
            for (NSDictionary *dict in newTweets) {
                Tweet *newTweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet" inManagedObjectContext:self.managedObjectContext];
                [newTweet setValue:[dict objectForKey:@"tweetid"] forKey:@"tweetid"];
                [newTweet setValue:[dict objectForKey:@"wsuid"] forKey:@"wsuid"];
                [newTweet setValue:[dict objectForKey:@"handle"] forKey:@"handle"];
                [newTweet setValue:[dict objectForKey:@"isdeleted"] forKey:@"isdeleted"];
                [newTweet setValue:[dict objectForKey:@"tstamp"] forKey:@"tstamp"];
                [newTweet setValue:[dict objectForKey:@"tweet"] forKey:@"tweet"];
                
                /* XXX
                [newTweet setTweetid:[dict objectForKey:@"tweetid"]];
                [newTweet setWsuid:[dict objectForKey:@"wsuid"]];
                [newTweet setHandle:[dict objectForKey:@"handle"]];
                [newTweet setIsdeleted:[dict objectForKey:@"isdeleted"]];
                [newTweet setTstamp:[dict objectForKey:@"tstamp"]];
                [newTweet setTweet:[dict objectForKey:@"tweet"]];
                */
                
                if ([[newTweet isdeleted] intValue] == 0) { // Add tweet to store
                    [self.managedObjectContext insertObject:newTweet];
                    [self.tweets addObject:newTweet];
                }
                
                /* Post notification  of new tweets */
                //NSLog(@"newTweet:%@ sizeTweets:%i", newTweet, [self.tweets count]);
                
            }
            [self.managedObjectContext save:&error];
        }
        self.getTweetsData = nil;
    } else if (connection == self.sendTweetsConnection) {
        NSLog(@"sendTweetsConnection");
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"WSUTwitterClient" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"WSUTwitterClient.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
