//
//  SignupViewController.h
//  Poopify
//
//  Created by Ian Eckles on 11/3/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include "Globals.h"

@interface SignupViewController : UIViewController <NSStreamDelegate,UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *userEmail;
@property (nonatomic, strong) IBOutlet UITextField *password;
@property (nonatomic, strong) IBOutlet UITextField *passwordVerify;

-(IBAction)submitPressed:(id)sender;
@end
