//
//  TweetEditorViewController.h
//  WSUTwitterClient
//
//  Created by Skylar Hiebert on 3/14/12.
//  Copyright (c) 2012 skylarhiebert.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@protocol EditTweetDelegate <NSObject>

-(void)addTweetWithHandle:(NSString*)handle WsuId:(NSString*)wsuid Tweet:(NSString*)tweet;

@end

@interface TweetEditorViewController : UIViewController

@property (weak, nonatomic) id<EditTweetDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *handleTextField;
@property (weak, nonatomic) IBOutlet UITextField *wsuidTextField;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet UILabel *charactersLeftTextField;
@property (strong, nonatomic) User *activeUser;

- (IBAction)editingDidEnd:(id)sender;

@end
