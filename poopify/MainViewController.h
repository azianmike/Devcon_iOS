//
//  MainViewController.h
//  Poopify
//
//  Created by Ian Eckles on 11/3/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignupViewController.h"
#import "MapViewController.h"
#import "ListViewController.h"
#import "AddNewLocationViewController.h"
#import "testLocationViewController.h"
#import "Globals.h"

@interface MainViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *login;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *signup;
@property (nonatomic, strong) IBOutlet UIButton *map;
@property (nonatomic, strong) IBOutlet UIButton *list;
@property (nonatomic, strong) IBOutlet CLLocation *currentLocation;
@property (nonatomic, strong) IBOutlet CLLocationManager *locationManager;


-(IBAction)mapsPressed:(id)sender;
-(IBAction)loginPressed:(id)sender;
-(IBAction)bathroomListPressed:(id)sender;
-(IBAction)signUpButtonPressed:(id)sender;
-(IBAction)newLocation:(id)sender;
-(IBAction)closestLocation:(id)sender;
-(void)changeButtonsToLoggedIn:(int) user_id;
-(IBAction)test:(id)sender;
@end
