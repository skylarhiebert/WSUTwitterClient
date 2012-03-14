//
//  TweetEditorViewController.m
//  WSUTwitterClient
//
//  Created by Skylar Hiebert on 3/14/12.
//  Copyright (c) 2012 skylarhiebert.com. All rights reserved.
//

#import "TweetEditorViewController.h"
#import "WSUTwitterClientAppDelegate.h"

@implementation TweetEditorViewController

@synthesize delegate;
@synthesize handleTextField;
@synthesize wsuidTextField;
@synthesize tweetTextField;
@synthesize charactersLeftTextField;

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
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(send:)];
    self.navigationItem.rightBarButtonItem = sendButton;
    
    // Notification for tweetTextField
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.tweetTextField];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [handleTextField becomeFirstResponder];
}

-(void)done:(id)sender {
    NSString *handle = self.handleTextField.text;
    NSString *wsuId = self.wsuidTextField.text;
    NSString *tweetText = self.tweetTextField.text;
    if ([handle length] == 0 || [wsuId length] == 0 || [tweetText length] == 0) {
        NSLog(@"empty fields");
    } else {
        [delegate addTweetWithHandle:handle WsuId:wsuId Tweet:tweetText];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)textFieldChanged:(id)sender {
    int maxChars = 140;
    int charsUsed = [self.tweetTextField.text length];
    NSLog(@"textFieldChanged:%i / %i", charsUsed, maxChars);
    charactersLeftTextField.text = [NSString stringWithFormat:@"%i/%i", charsUsed, maxChars];
}

- (void)viewDidUnload
{
    [self setHandleTextField:nil];
    [self setWsuidTextField:nil];
    [self setTweetTextField:nil];
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
