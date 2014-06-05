//
//  AddCommentViewController.h
//  Poopify
//
//  Created by Ian Eckles on 11/17/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bathroom.h"
#import "Comment.h"
#import "Globals.h"

@interface AddCommentViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *comment;
@property BOOL firstLoad;
@property Bathroom *bathroom;

-(IBAction)cancelButton:(id)sender;
-(IBAction)submitComment:(id)sender;
@end
