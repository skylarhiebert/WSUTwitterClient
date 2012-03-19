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
@synthesize lastRefreshDateString = _lastRefreshDateString;
@synthesize lastRefreshDate = _lastRefreshDate;
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
    
    // Load persistant store
    NSManagedObjectContext *context = self.managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tweet" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results == nil) {
        NSLog(@"fetch error: %@ (%@)", error, [error userInfo]);
        abort();
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];                
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
    self.lastRefreshDateString = @"1970-01-01 00:00:00"; // Unix Epoch
    self.lastRefreshDate = [dateFormatter dateFromString:self.lastRefreshDateString];
    if ([results count] > 0) {     
        self.tweets = [results mutableCopy]; 
        
        /* Iterate through results and update refresh date */
        for (Tweet *t in self.tweets) {
            NSDate *newDate = [dateFormatter dateFromString:t.tstamp];
            if ([newDate compare:self.lastRefreshDate] == (NSComparisonResult)NSOrderedDescending) {
                NSLog(@"Updating %@ to %@", self.lastRefreshDate, newDate);
                self.lastRefreshDate = [newDate laterDate:self.lastRefreshDate];
                self.lastRefreshDateString = [dateFormatter stringFromDate:self.lastRefreshDate];
            } 
        }
        // Sort the tweet array
        [self.tweets sortUsingComparator:^(id a, id b) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];                
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
            NSDate *first = [dateFormatter dateFromString:[a valueForKey:@"tstamp"]];
            NSDate *second = [dateFormatter dateFromString:[b valueForKey:@"tstamp"]];
            
            return [second compare:first];
        }];
        
    } else {

        self.tweets = [[NSMutableArray alloc] init];
        
    }
        
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

static NSString *makeSafeForURLArgument(NSString *str) {
    CFStringRef cfStr = (__bridge_retained CFStringRef)str;
    CFStringRef chars = CFSTR("!*'();:@+$,/?%#[]");
    CFStringRef preppedString = CFURLCreateStringByAddingPercentEscapes(NULL, cfStr, NULL,  chars, kCFStringEncodingUTF8);
    NSLog(@"Encoded String:%@", preppedString);
    return (__bridge_transfer NSString *)preppedString;
    
    /* XXX
    NSMutableString *temp = [str mutableCopy];
    [temp replaceOccurrencesOfString:@"?"
                          withString:@"%3F"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"="
                          withString:@"%3D"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&"
                          withString:@"%26"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    return temp;
     */
}

- (void)refreshTweets {
    NSLog(@"refreshTweets");
    // Start Activity indicator
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    // Format refresh string
    static NSString *getTweetCGI = @"http://ezekiel.vancouver.wsu.edu/~cs458/cgi-bin/get-tweets.cgi";
    NSString *encodedDateString = [self.lastRefreshDateString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *query = [NSString stringWithFormat:@"%@?date=%@", getTweetCGI, encodedDateString];
    NSURL *url = [NSURL URLWithString:query];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    self.getTweetsConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (self.getTweetsConnection) {
        self.getTweetsData = [[NSMutableData alloc] init]; 
    } else {
        NSLog(@"Error in refreshTweetsWithURL:%@", url);
    }
}

- (void)sendTweetWithHandle:(NSString*)handle WsuId:(NSString*)wsuid Tweet:(NSString*)tweet {
    NSLog(@"sendTweetWithHandle:%@ WsuId:%@ Tweet:%@", handle, wsuid, tweet);
    
    // Start Activity indicator
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    // Format send string
    static NSString *tweetSendCGI = @"http://ezekiel.vancouver.wsu.edu/~cs458/cgi-bin/add-tweet.cgi";
    NSString *urlEncodedTweet = makeSafeForURLArgument(tweet);
    NSString *urlEncodedHandle = makeSafeForURLArgument(handle);
    NSString *encdedWSUID = [wsuid stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *query = [NSString stringWithFormat:@"%@?handle=%@&wsuid=%@&tweet=%@", tweetSendCGI, urlEncodedHandle, encdedWSUID, urlEncodedTweet];
    NSURL *url = [NSURL URLWithString:query];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    self.sendTweetsConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (self.sendTweetsConnection) {
        self.sendTweetsData = [[NSMutableData alloc] init];
    } else {
        NSLog(@"Error in sendTweetWithURL:%@", url);
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
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];                
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
        
        if ([newTweets count] > 0) {          
            // Convert from array of dictionaries to array of Tweets
            // Add to persistant store
            for (NSDictionary *dict in newTweets) {
                /* Check if persistant store has tweet already */
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tweet" inManagedObjectContext:self.managedObjectContext];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(tweetid = %d)", [dict objectForKey:@"tweetid"]]; 
                [request setEntity:entity];
                [request setPredicate:predicate];
                
                NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:&error];
                
                if (nil == objects) {
                    NSLog(@"There was an error in connectionDidFinishLoading:%@", error);
                    abort();
                }
                
                
                if ([objects count] > 0) {
                    NSLog(@"Tweet %@ already in persistant store", [dict objectForKey:@"tweetid"]);
                } else { /* Add Tweet if not in persistant store */
                    if ([[dict objectForKey:@"isdeleted"] intValue] != 0) {
                        NSLog(@"Tweet is in deleted state");
                    } else { // Add tweet to store
                        Tweet *newTweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet" inManagedObjectContext:self.managedObjectContext];
                        [newTweet setValue:[dict objectForKey:@"tweetid"] forKey:@"tweetid"];
                        [newTweet setValue:[dict objectForKey:@"wsuid"] forKey:@"wsuid"];
                        [newTweet setValue:[dict objectForKey:@"handle"] forKey:@"handle"];
                        [newTweet setValue:[dict objectForKey:@"isdeleted"] forKey:@"isdeleted"];
                        [newTweet setValue:[dict objectForKey:@"tstamp"] forKey:@"tstamp"];
                        [newTweet setValue:[dict objectForKey:@"tweet"] forKey:@"tweet"];
                        
                        //NSLog(@"Adding Tweet %@ to persistant store", newTweet);
                        NSDate *newDate = [dateFormatter dateFromString:[newTweet tstamp]];
                        if ([newDate laterDate:self.lastRefreshDate]) {
                            self.lastRefreshDateString = [newTweet tstamp];
                            self.lastRefreshDate = [dateFormatter dateFromString:self.lastRefreshDateString];
                        }
                        [self.tweets addObject:newTweet]; // Add to the view array    
                    }
                }
                
                // Sort the tweets
                [self.tweets sortUsingComparator:^(id a, id b) {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];                
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
                    NSDate *first = [dateFormatter dateFromString:[a valueForKey:@"tstamp"]];
                    NSDate *second = [dateFormatter dateFromString:[b valueForKey:@"tstamp"]];
                    
                    return [second compare:first];
                }];
                
                /* Post notification  of new tweets */
                [[NSNotificationCenter defaultCenter] postNotificationName:@"tweetsFinishedLoading" object:nil];
                
            }
            [self.managedObjectContext save:&error];
        }
        self.getTweetsData = nil;
    } else if (connection == self.sendTweetsConnection) {
        NSError *error;
        NSArray *sendResults = [NSPropertyListSerialization propertyListWithData:self.sendTweetsData options:NSPropertyListMutableContainersAndLeaves format:NULL error:&error];
        if ([[sendResults valueForKey:@"success"] intValue] == 0) {
            NSLog(@"Failure: %@", [sendResults valueForKey:@"info"]);
            NSString *errorMessage = [NSString stringWithFormat:@"An error occurred sending tweet: %@", [sendResults valueForKey:@"info"]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" 
                                                            message:errorMessage
                                                           delegate:self 
                                                  cancelButtonTitle:@"Okay" 
                                                  otherButtonTitles:nil];
            [alert setTag:1];
            [alert show];
        }
        [self refreshTweets];
    }
    // Turn off activity indicator
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
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
        //[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        abort();
    }    
    //[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
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
