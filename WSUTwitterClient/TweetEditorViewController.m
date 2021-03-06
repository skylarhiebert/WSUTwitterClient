//
//  TweetEditorViewController.m
//  WSUTwitterClient
//
//  Created by Skylar Hiebert on 3/14/12.
//  Copyright (c) 2012 skylarhiebert.com. All rights reserved.
//

#define MAXCHARS 140

#import <QuartzCore/QuartzCore.h>
#import "TweetEditorViewController.h"
#import "WSUTwitterClientAppDelegate.h"
#import "User.h"

@implementation TweetEditorViewController

@synthesize delegate;
@synthesize handleTextField;
@synthesize wsuidTextField;
@synthesize tweetTextView;
@synthesize charactersLeftTextField;
@synthesize activeUser;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    
    // Load persistant store
    WSUTwitterClientAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results == nil) {
        NSLog(@"fetch error: %@ (%@)", error, [error userInfo]);
        abort();
    } else if ([results count] > 0) {
        /* Set the handle and wsuid fields */
        activeUser = [results objectAtIndex:0];
        self.handleTextField.text = activeUser.handle;
        self.wsuidTextField.text = activeUser.wsuid;
    } else {
        /* Create new user in persistant store */
        activeUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:appDelegate.managedObjectContext];
    }

    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(send:)];
    self.navigationItem.rightBarButtonItem = sendButton;
    
    // Initialize tweetTextView
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewChanged:) name:UITextViewTextDidChangeNotification object:self.tweetTextView];
    self.tweetTextView.text = @"";
    self.tweetTextView.layer.borderWidth = 1.0;
    self.tweetTextView.layer.borderColor = [[UIColor blackColor] CGColor];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [handleTextField becomeFirstResponder];
}

-(void)send:(id)sender {
    NSString *handle = self.handleTextField.text;
    NSString *wsuId = self.wsuidTextField.text;
    NSString *tweetText = self.tweetTextView.text;
    if ([handle length] == 0 || [wsuId length] == 0 || [tweetText length] == 0) {
        NSLog(@"empty fields");
    } else {
        /* Save the user information in persistant store */
        activeUser.handle = handle;
        activeUser.wsuid = wsuId;
        WSUTwitterClientAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = appDelegate.managedObjectContext;
        NSError *error;
        [context save:&error];
        
        [delegate addTweetWithHandle:handle WsuId:wsuId Tweet:tweetText];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

// Edit the label to display the correct number of characters used
-(void)textViewChanged:(id)sender {
    int charsUsed = [self.tweetTextView.text length];
    charactersLeftTextField.text = [NSString stringWithFormat:@"%i / %i", charsUsed, MAXCHARS];
}

// Limit the number of characters to MAXCHARS
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if(range.length > text.length){
        return YES;
    }else if([[textView text] length] + text.length > MAXCHARS){
        return NO;
    }
    
    return YES;
}

- (void)viewDidUnload
{
    [self setHandleTextField:nil];
    [self setWsuidTextField:nil];
    [self setTweetTextView:nil];
    [self setCharactersLeftTextField:nil];
    [self setTweetTextView:nil];
    [self setTweetTextView:nil];
    [self setCharactersLeftTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)editingDidEnd:(id)sender {
    [sender resignFirstResponder];
}

@end
