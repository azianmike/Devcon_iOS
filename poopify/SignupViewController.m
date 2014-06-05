//
//  SignupViewController.m
//  Poopify
//
//  Created by Ian Eckles on 11/3/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import "SignupViewController.h"

const static NSInteger SUCCESS = 1;
const static NSInteger FAILED = 2;
const static NSInteger PASSNOMATCH = 3;
const static NSInteger NOPASS = 4;
const static NSInteger BADEMAIL = 5;

@interface SignupViewController ()

@end

@implementation SignupViewController

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
    [self.userEmail setDelegate:self];
    [self.password setDelegate:self];
    [self.passwordVerify setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)submitPressed:(id)sender
{
    // Check to see if the passwords match and the email is an email
    NSString *email = [self.userEmail text];
    NSString *password = [self.password text];
    NSString *passwordVerify = [self.passwordVerify text];
    
    if([self emailValid:email]) // Checks if email is valid
    {
        if(password.length > 0)
        {
            if([password isEqualToString:passwordVerify])
            {
                // hash the password
                NSString * hashedPass = [Globals hashed_string:password];
                
                // Make data to send to the server
                NSMutableDictionary *signupData = [[NSMutableDictionary alloc]init];
                [signupData setObject:@"signup" forKey:@"function"];
                [signupData setObject:email forKey:@"user_email"];
                [signupData setObject:hashedPass forKey:@"password"];
                
                NSData *t = [Globals accessServer:signupData needResponse:TRUE];
                int returnValue = [[[NSString alloc] initWithData:t encoding:NSUTF8StringEncoding] intValue];
                
                if(returnValue == -1) // Did not create account
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Signup Failed" message:@"The user already exists. Please enter a new email" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                    [alert setTag:FAILED];
                    [alert show];
                }
                else if(returnValue == 1) // Created account successful
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Signup Succesful" message:@"User created!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                    [alert setTag:SUCCESS];
                    [alert show];
                }
            }
            else
            {
                // Passwords do not match
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Signup Failed" message:@"The two passwords do not match!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                [alert setTag:PASSNOMATCH];
                [alert show];
            }
        }
        else
        {
            // Password length is zero
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Signup Failed" message:@"Please enter a password!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alert setTag:NOPASS];
            [alert show];
        }
    }
    else
    {
        // Email is not valid
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Signup Failed" message:@"Please enter a valid email!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert setTag:BADEMAIL];
        [alert show];
    }
}

// checks if the email is valid
// Dont know how to correctly cite this but
// it is from http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
-(BOOL)emailValid:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

// Alertview clicked
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView tag] == SUCCESS)
    {
        [self.navigationController popViewControllerAnimated:TRUE];
    }
    else if([alertView tag] == FAILED)
    {
        [self.userEmail setText:@""];
        [self.password setText:@""];
        [self.passwordVerify setText:@""];
    }
    else if([alertView tag] == BADEMAIL)
    {
        [self.userEmail setText:@""];
        [self.password setText:@""];
        [self.passwordVerify setText:@""];
    }
    else if([alertView tag] == NOPASS)
    {
        [self.passwordVerify setText:@""];
        [self.password setText:@""];
    }
    else if([alertView tag] == PASSNOMATCH)
    {
        [self.passwordVerify setText:@""];
        [self.password setText:@""];
    }
}

// Function to dismiss the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
