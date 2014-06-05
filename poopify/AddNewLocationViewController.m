//
//  AddNewLocationViewController.m
//  Poopify
//
//  Created by Ian Eckles on 11/3/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import "AddNewLocationViewController.h"
#define METERS_PER_MILE 1609.344

@interface AddNewLocationViewController ()

@end

@implementation AddNewLocationViewController

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
    self.buildingName.delegate = self;
    self.description.delegate = self;
    self.map.delegate = self;
    self.firstLoad = TRUE;
    self.map.showsUserLocation = YES;
    self.upPressed = FALSE;
    self.downPressed = FALSE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Map bullshit
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if(self.firstLoad)
    {
        [self centerView];
        self.firstLoad=FALSE;
    }
}
- (void) centerView {
    CLLocationCoordinate2D zoomLocation = _map.userLocation.coordinate;
    
    //if we are unable to read userLocation, let the updateUserLocation callback
    //continue to get called
    if ( zoomLocation.latitude == 0 &&
        zoomLocation.longitude == 0 )
    {
        self.firstLoad = TRUE;
    }
    NSLog(@"(%f,%f)",zoomLocation.latitude, zoomLocation.longitude);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, .5*METERS_PER_MILE, .5*METERS_PER_MILE);
    
    [_map setRegion:viewRegion animated:YES];
}


// Function to dismiss the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
// Function to dismiss the keyboard
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [self keyboardDidHide];
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self keyboardDidShow];
}

// Scrolling keyboard
- (void)keyboardDidShow
{
    //Assign new frame to your view
    [self.view setFrame:CGRectMake(0,-130,320,568)]; //here taken -20 for example i.e. your view will be scrolled to -20. change its value according to your requirement.
    
}

-(void)keyboardDidHide
{
    [self.view setFrame:CGRectMake(0,0,320,568)];
}

// Change the colors of the buttons when pressed
-(IBAction)upButtonClicked:(id)sender
{
    if(self.upPressed) // Up button already selected
    {
        [self.upButton setImage:[UIImage imageNamed:@"thumbsUp.png"] forState:UIControlStateNormal];
        self.upPressed = FALSE;
    }
    else
    {
        [self.downButton setImage:[UIImage imageNamed:@"thumbsDown.png"] forState:UIControlStateNormal];
        [self.upButton setImage:[UIImage imageNamed:@"thumbsUpBlue.png"] forState:UIControlStateNormal];
        self.upPressed = TRUE;
        self.downPressed = FALSE;
    }
}
// Change the colors of the buttons when pressed
-(IBAction)downButtonClicked:(id)sender
{
    if(self.downPressed)
    {
        [self.downButton setImage:[UIImage imageNamed:@"thumbsDown.png"] forState:UIControlStateNormal];
        self.downPressed = FALSE;
    }
    else
    {
        [self.downButton setImage:[UIImage imageNamed:@"thumbsDownBlue.png"] forState:UIControlStateNormal];
        [self.upButton setImage:[UIImage imageNamed:@"thumbsUp.png"] forState:UIControlStateNormal];
        self.downPressed = TRUE;
        self.upPressed = FALSE;
    }
}

// Submit the data to the server and try and add the location
-(IBAction)submitNewLocation:(id)sender
{
    // Check if location name if put in
    if([[self.buildingName text] length] == 0)
    {
        UIAlertView *noBuildingName = [[UIAlertView alloc]initWithTitle:@"No Building Name" message:@"Please enter a Building Name" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [noBuildingName show];
        return;
    }
    
    NSString *location_name = [self.buildingName text];
    int user_id = [[NSUserDefaults standardUserDefaults]integerForKey:@"user_id"];
    NSString *thumbsUp;
    if([self upPressed])
    {
        thumbsUp = @"True";
    }
    else if([self downPressed])
    {
        thumbsUp = @"False";
    }
    else // if neither thumbs up or down is selected
    {
        UIAlertView *chooseRating = [[UIAlertView alloc]initWithTitle:@"Choose Rating" message:@"Please select the thumbs up or thumbs down icon for this bathroom" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [chooseRating show];
        return;
    }
    
    NSString *comment = [self.description text];
    double latitude = [[self.map userLocation] coordinate].latitude;
    double longitude = [[self.map userLocation] coordinate].longitude;
    
    // Make data to send to the server
    NSMutableDictionary *addLocationData = [[NSMutableDictionary alloc]init];
    [addLocationData setObject:@"addLocation" forKey:@"function"];
    [addLocationData setObject:[NSNumber numberWithInt:user_id] forKey:@"user_id"];
    [addLocationData setObject:thumbsUp forKey:@"thumbsUp"];
    [addLocationData setObject:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
    [addLocationData setObject:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
    [addLocationData setObject:comment forKey:@"comment"];
    [addLocationData setObject:location_name forKey:@"location_name"];
    
    NSData *t = [Globals accessServer:addLocationData needResponse:TRUE];
    int returnValue = [[[NSString alloc] initWithData:t encoding:NSUTF8StringEncoding] intValue];
    
    if(returnValue == -1) // add did not work because there is a location too close
    {
        UIAlertView *didntAdd = [[UIAlertView alloc]initWithTitle:@"Add Location Failed" message:@"There is already a location for your current location. Look it up on the map or list view!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [didntAdd show];
    }
    else // location added successfully
    {
        UIAlertView *worked = [[UIAlertView alloc]initWithTitle:@"Location Added Successfully" message:@"Your current location was added successfully!" delegate:self cancelButtonTitle:@"Wooo!" otherButtonTitles:nil];
        [worked show];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:TRUE];
}

@end
