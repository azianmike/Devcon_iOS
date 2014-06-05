//
//  AddCommentViewController.m
//  Poopify
//
//  Created by Ian Eckles on 11/17/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import "AddCommentViewController.h"

@interface AddCommentViewController ()

@end

@implementation AddCommentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.firstLoad = TRUE;
    self.navigationController.navigationBar.hidden = YES;
    self.comment.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Function to dismiss the keyboard
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if(self.firstLoad)
    {
        [textView setText:@""];
        self.firstLoad = FALSE;
    }
    return YES;
}

-(IBAction)cancelButton:(id)sender
{
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)submitComment:(id)sender
{
    if(!self.firstLoad && [[self.comment text] length] != 0)
    {
        int user_id = (int)[[NSUserDefaults standardUserDefaults]integerForKey:@"user_id"];
        NSString *comment = [self.comment text];
        
        // Make data to send to the server
        NSMutableDictionary *addCommentData = [[NSMutableDictionary alloc]init];
        [addCommentData setObject:@"addComment" forKey:@"function"];
        [addCommentData setObject:[NSString stringWithFormat:@"%d", user_id] forKey:@"user_id"];
        [addCommentData setObject:[NSString stringWithFormat:@"%d", self.bathroom.location_id] forKey:@"location_id"];
        [addCommentData setObject:comment forKey:@"comment"];
        
        NSData *t = [Globals accessServer:addCommentData needResponse:YES];
        int returnValue = [[[NSString alloc] initWithData:t encoding:NSUTF8StringEncoding] intValue];
        
        if(returnValue == 1) // comment added successfully
        {
            Comment *newComment = [[Comment alloc]init];
            newComment.comment = comment;
            newComment.user_id = user_id;
            [self.bathroom.comments addObject:newComment];
            UIAlertView *worked = [[UIAlertView alloc]initWithTitle:@"Comment Added Successfully" message:@"Your comment was added successfully!" delegate:self cancelButtonTitle:@"Wooo!" otherButtonTitles:nil];
            [worked setTag:0];
            [worked show];
        }
        else // comment not added
        {
            
        }
    }
    else // did not enter in a comment
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Comment Failed" message:@"Please enter a comment below" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert setTag:1];
        [alert show];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView tag] == 0)
    {
        [self cancelButton:nil];
    }
}

@end
