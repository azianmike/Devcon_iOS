//
//  MainViewController.m
//  Poopify
//
//  Created by Ian Eckles on 11/3/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import "MainViewController.h"

const static NSInteger LOGIN = 1;
const static NSInteger SIGNUP = 2;

@interface MainViewController ()

@end

@implementation MainViewController

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
    // Check and see if the user is logged in
    int user_id = [[NSUserDefaults standardUserDefaults]integerForKey:@"user_id"];
    if(user_id != 0)
    {
        [self changeButtonsToLoggedIn:user_id];
    }
    
    self.currentLocation = nil;
    
    if([CLLocationManager locationServicesEnabled])
    {
        // Grab the users location
        NSLog(@"Getting users Location");
        self.locationManager = [[CLLocationManager alloc]init];
       self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Location Error" message:@"Please enable location services for Poopify." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
}

-(void) locationManager: (CLLocationManager *)manager didUpdateToLocation: (CLLocation *) newLocation fromLocation: (CLLocation *) oldLocation
{
    NSLog(@"User location updated");
    self.currentLocation = newLocation;
    [self.locationManager stopUpdatingLocation];
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Location Error" message:@"There was an error when we tried to find your location! Make sure location services is enabled! Please try again." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Sign up button was pressed
-(IBAction)signUpButtonPressed:(id)sender
{
    if([[sender title] isEqualToString:@"Signup"])
    {
        SignupViewController *signupView = [self.storyboard instantiateViewControllerWithIdentifier:@"SignupViewController"];
        [self.navigationController pushViewController:signupView animated:YES];
    }
    else if([[sender title] isEqualToString:@"Logout"])
    {
        // Get rid of the user_id
        [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:@"user_id"];
        [self.signup setTitle:@"Signup"];
        [self.navigationItem setLeftBarButtonItem:[self login] animated:YES];
        [self.navigationItem setTitle:@"Poopify"];
    }
}


-(IBAction)mapsPressed:(id)sender
{
    /*
    UIAlertView *alert = [[UIAlertView alloc]init];
    alert.message = @"Pressed the map";
    [alert addButtonWithTitle:@"OK"];
    [alert show];*/
    MapViewController *mapView = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    [self.navigationController pushViewController:mapView animated:YES];
}

-(IBAction)loginPressed:(id)sender
{
    UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Login" message:@"Enter Username and Password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Login" ,nil];
    [loginAlert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [loginAlert setTag:LOGIN];
    [loginAlert show];
}

-(IBAction)bathroomListPressed:(id)sender
{
    /*UIAlertView *alert = [[UIAlertView alloc]init];
    alert.message = @"Pressed bathroom list";
    [alert addButtonWithTitle:@"OK"];
    [alert show];*/
    ListViewController *listView = [self.storyboard instantiateViewControllerWithIdentifier:@"ListViewController"];
    [self.navigationController pushViewController:listView animated:YES];
}

-(IBAction)newLocation:(id)sender
{
    // Check to see a user is logged in
    // Only able to add location if logged in
    int user_id = [[NSUserDefaults standardUserDefaults]integerForKey:@"user_id"];
    if(user_id != 0)
    {
        AddNewLocationViewController *newLocation = [self.storyboard instantiateViewControllerWithIdentifier:@"AddNewLocationViewController"];
        [self.navigationController pushViewController:newLocation animated:YES];
    }
    else
    {
        UIAlertView *notLoggedIn = [[UIAlertView alloc]initWithTitle:@"No User Logged In" message:@"You must be logged in to an account to add a location. Please login or create and account!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [notLoggedIn show];
    }
}

- (void)doneLoadingClosestLocation:(Bathroom *) tempBathroom
{
    // Remove the loading screen
    [[self.view.subviews lastObject] removeFromSuperview];
    
    // Get the new view ready
    testLocationViewController *locationView = [self.storyboard instantiateViewControllerWithIdentifier:@"test"];
    locationView.bathroom = tempBathroom;
    [self.navigationController pushViewController:locationView animated:NO];
}

-(IBAction)closestLocation:(id)sender
{
    if(self.currentLocation != nil)
    {
        // Add the loading screen
        UILoadingView *loadingView = [[UILoadingView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:loadingView];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableDictionary *getLocationData = [[NSMutableDictionary alloc]init];
            [getLocationData setObject:[NSNumber numberWithDouble:self.currentLocation.coordinate.latitude] forKey:@"latitude"];
            [getLocationData setObject:[NSNumber numberWithDouble:self.currentLocation.coordinate.longitude] forKey:@"longitude"];
            [getLocationData setObject:@"getClosestLocation" forKey:@"function"];
            NSData *t = [Globals accessServer:getLocationData needResponse:TRUE];
            
            // Parse the JSON
            Bathroom *tempBathroom;
            NSDictionary *tempData = [NSJSONSerialization JSONObjectWithData:t options:0 error:nil];
            NSDictionary *comments = [tempData objectForKey:@"commentArray"];
            CLLocationDegrees latitude = [[tempData objectForKey:@"latitude"] doubleValue];
            CLLocationDegrees longitude = [[tempData objectForKey:@"longitude"] doubleValue];
            CLLocation *loc = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
            tempBathroom = [[Bathroom alloc]initWithName:[tempData objectForKey:@"location_name"] Location:loc upNumber:[[tempData objectForKey:@"thumbsUp"] intValue] downNumber:[[tempData objectForKey:@"thumbsDown"] intValue] locationID: [[tempData objectForKey:@"location_id"] intValue]];
            NSMutableArray *commentsArray = [[NSMutableArray alloc]init];
            for(NSDictionary *tempComment in comments)
            {
                Comment *com = [[Comment alloc]init];
                com.user_id = [[tempComment objectForKey:@"user_id"] intValue];
                com.comment = [tempComment objectForKey:@"comment"];
                [commentsArray addObject:com];
            }
            tempBathroom.comments = commentsArray;
            
            [self performSelectorOnMainThread:@selector(doneLoadingClosestLocation:) withObject:tempBathroom waitUntilDone:NO];
        });
    }
}

-(void)changeButtonsToLoggedIn:(int) user_id
{
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    [self.signup setTitle:@"Logout"];
    [self.navigationItem setTitle:[NSString stringWithFormat:@"Poopify - User: %d", user_id]];
}

// Method called when the clicks on UIAlertView
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView tag] == LOGIN)
    {
        if(buttonIndex != 0) // 0 is the cancel button
        {
            NSString *userEmail = [[alertView textFieldAtIndex:0] text];
            NSString *pass = [[alertView textFieldAtIndex:1] text];
            NSString *hashedPass = [Globals hashed_string:pass];
            
            // Make data to send to the server
            NSMutableDictionary *signinData = [[NSMutableDictionary alloc]init];
            [signinData setObject:@"login" forKey:@"function"];
            [signinData setObject:userEmail forKey:@"user_email"];
            [signinData setObject:hashedPass forKey:@"password"];
            
            NSData *t = [Globals accessServer:signinData needResponse:YES];
            
            int returnValue = [[[NSString alloc] initWithData:t encoding:NSUTF8StringEncoding] intValue];
            
            if(returnValue == -1) // Login failed, wrong combination
            {
                UIAlertView *wrongPassword = [[UIAlertView alloc]initWithTitle:@"Login Failed" message:@"The Email/Password combination does not match our system. Please try again." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                [wrongPassword show];
            }
            else // returned value is the user_id
            {
                // save the user_id for later use
                [[NSUserDefaults standardUserDefaults] setInteger:returnValue forKey:@"user_id"];
                // hide the login and signup buttons and replace with a signout button
                [self changeButtonsToLoggedIn:returnValue];
            }
        }
    }
}

-(IBAction)test:(id)sender
{
    UIImage *image = [UIImage imageNamed:@"small.jpg"];
    NSData *data = UIImageJPEGRepresentation(image, .5);
    NSLog([NSString stringWithFormat:@"%d"],[data length]);
    //NSLog(@"%@", data);
    NSString *base64 = [[NSString alloc]initWithData:[data base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength] encoding:NSUTF8StringEncoding];
    NSLog(base64);
    
    // Make data to send to the server
    NSMutableDictionary *getLocationData = [[NSMutableDictionary alloc]init];
    [getLocationData setObject:@"addPicture" forKey:@"function"];
    [getLocationData setObject:base64 forKey:@"data"];
    [Globals accessServer:getLocationData needResponse:NO];
}
@end
