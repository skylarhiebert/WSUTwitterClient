//
//  TweetsTableViewController.m
//  WSUTwitterClient
//
//  Created by Skylar Hiebert on 3/13/12.
//  Copyright (c) 2012 skylarhiebert.com. All rights reserved.
//

#import "TweetsTableViewController.h"
#import "WSUTwitterClientAppDelegate.h"
#import "TweetEditorViewController.h"
#import "Tweet.h"

@implementation TweetsTableViewController {
    NSOperationQueue *operationQueue;
}

@synthesize appDelegate = _appDelegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.appDelegate = [[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Create the interface buttons
    self.title = @"Tweets";
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newTweet:)];
    self.navigationItem.rightBarButtonItem = addButton;
    UIBarButtonItem *getTweetsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(getTweets:)];
    self.navigationItem.leftBarButtonItem = getTweetsButton;
    
    // NEED IMPLEMENTATION DETAILS 
    // Fetch the cached copy of tweets
  /*  NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tweet" inManagedObjectContext:_appDelegate.managedObjectContext];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *results = [_appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    if (results == nil) {
        NSLog(@"fetch error: %@ (%@)", error, [error userInfo]);
        abort();
    }
    
    _appDelegate.tweets = [results mutableCopy]; */
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - callbacks


- (void) getTweets:(id)sender {
    NSLog(@"getTweets:");
    //operationQueue = [[NSOperationQueue alloc] init];
    //NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(fetchTweets:) object:nil];
    //[operationQueue addOperation:op];
}
/*
- (void) fetchTweets:(id)object {
    NSLog(@"fetchTweets:");
    // Create Date format and initial refresh date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
    NSString *refreshDateString = @"1970-01-01 00:00:00"; // Unix Epoch
    NSDate *refreshDate = [dateFormatter dateFromString:refreshDateString];
    
    // Iterate through existing/stored tweets and update refresh date
    WSUTwitterClientAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    for (NSDictionary *dict in appDelegate.tweets) {
        if ([refreshDateString compare:[dict objectForKey:@"tstamp"]] > 0) {
            refreshDateString = [dict objectForKey:@"tstamp"];
            refreshDate = [dateFormatter dateFromString:refreshDateString];
        }
    }
    
    // Create refresh URL
    NSURL *url = [NSURL URLWithString:@"http://ezekiel.vancouver.wsu.edu/~wayne/cgi-bin/get-tweets.cgi?date=2012-03-12%2015:30:00"];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfURL:url];
    
    
    // Convert from array of dictionaries to array of Tweets
    for (NSDictionary *dict in array) {
        Tweet *newTweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet" inManagedObjectContext:_appDelegate.managedObjectContext];
        [newTweet setTweetid:[dict objectForKey:@"tweetid"]];
        [newTweet setWsuid:[dict objectForKey:@"wsuid"]];
        [newTweet setHandle:[dict objectForKey:@"handle"]];
        [newTweet setIsdeleted:[dict objectForKey:@"isdeleted"]];
        [newTweet setTstamp:[dict objectForKey:@"tstamp"]];
        [newTweet setTweet:[dict objectForKey:@"tweet"]];
        
        if ([[newTweet isdeleted] intValue] == 0) { // Add tweet to store
            [_appDelegate.managedObjectContext insertObject:newTweet];
            [_appDelegate.tweets addObject:newTweet];
        }
        [self.tableView reloadData];
        //NSLog(@"newTweet:%@ sizeTweets:%i", newTweet, [self.tweets count]);
        
    }
}

-(void)addTweetWithId:(NSNumber *)tweetid wsuId:(NSString *)wsuid Handle:(NSString *)handle isDeleted:(NSNumber *)isdeleted TStamp:(NSString *)tstamp Tweet:(NSString *)tweet {
    Tweet *newTweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet" inManagedObjectContext:_appDelegate.managedObjectContext];
    [newTweet setTweetid:tweetid];
    [newTweet setWsuid:wsuid];
    [newTweet setHandle:handle];
    [newTweet setIsdeleted:isdeleted];
    [newTweet setTstamp:tstamp];
    [newTweet setTweet:tweet];

    NSError *error;
    if(![_appDelegate.managedObjectContext save:&error]) {
        NSLog(@"add error: %@ (%@)", error, [error userInfo]);
        abort();
    }
    
    if ([[newTweet isdeleted] intValue] == 0) {
        [_appDelegate.tweets addObject:newTweet];
    }
    
    [self.tableView reloadData];
}
*/

-(void)addTweetWithHandle:(NSString*)handle WsuId:(NSString*)wsuid Tweet:(NSString*)tweet {
    
}

- (void) newTweet:(id)sender {
    NSLog(@"newTweet:");
    TweetEditorViewController *viewController = [[TweetEditorViewController alloc] initWithNibName:nil bundle:nil];
    viewController.delegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    WSUTwitterClientAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSDictionary *dict = [appDelegate.tweets objectAtIndex:indexPath.row];
    NSString *tweet = [dict objectForKey:@"tweet"];
    UIFont *font = [UIFont systemFontOfSize:17];
    CGSize maxSize = CGSizeMake(230, 999.0);
    CGSize size = [tweet sizeWithFont:font constrainedToSize:maxSize lineBreakMode:UILineBreakModeTailTruncation];
    return size.height + 20;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    WSUTwitterClientAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return [appDelegate.tweets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    WSUTwitterClientAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    Tweet *tweet = [appDelegate.tweets objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%@) - %@", tweet.handle, tweet.wsuid, tweet.tstamp];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [UIColor blueColor];
    cell.detailTextLabel.text = tweet.tweet;
    cell.detailTextLabel.numberOfLines = 0; // Multi-line label
    cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
