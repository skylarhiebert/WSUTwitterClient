//
//  TweetsTableViewController.h
//  WSUTwitterClient
//
//  Created by Skylar Hiebert on 3/13/12.
//  Copyright (c) 2012 skylarhiebert.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSUTwitterClientAppDelegate.h"
#import "TweetEditorViewController.h"

@interface TweetsTableViewController : UITableViewController <EditTweetDelegate>

//@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//@property (strong, nonatomic) NSMutableArray *tweets;
@property (weak, nonatomic) WSUTwitterClientAppDelegate *appDelegate ;

@end
