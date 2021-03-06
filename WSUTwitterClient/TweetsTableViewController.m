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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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
    
    // Add notification center observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTweets) name:@"tweetsFinishedLoading" object:nil];
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

- (void) reloadTweets {
    [self.tableView reloadData];
}

- (void) getTweets:(id)sender {
    NSLog(@"getTweets:");
    WSUTwitterClientAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate refreshTweets];
}

   
-(void)addTweetWithHandle:(NSString*)handle WsuId:(NSString*)wsuid Tweet:(NSString*)tweet {
    WSUTwitterClientAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSLog(@"Adding Tweet");
    [appDelegate  sendTweetWithHandle:handle WsuId:wsuid Tweet:tweet];
}

- (void) newTweet:(id)sender {
    NSLog(@"newTweet:");
    TweetEditorViewController *viewController = [[TweetEditorViewController alloc] initWithNibName:nil bundle:nil];
    viewController.delegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)deleteTweet:(id)sender {
    
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    WSUTwitterClientAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    Tweet *dict = [appDelegate.tweets objectAtIndex:indexPath.row];
    NSString *tweet = dict.tweet;
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
