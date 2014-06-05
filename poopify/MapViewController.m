//
//  MapViewController.m
//  Poopify
//
//  Created by Ian Eckles on 11/3/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import "MapViewController.h"
#define METERS_PER_MILE 1609.344
@interface MapViewController ()

@end

@implementation MapViewController

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
    NSLog(@"DID LOAD");
	// Do any additional setup after loading the view.
    _map.delegate = self;
    _map.showsUserLocation = YES;
    _firstLoad = TRUE;
    self.selectedBathroom = nil;
    self.selectedBathroomAnnotation = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    if(self.selectedBathroom != nil)
    {
        float thumbsUpPercent = 0;
        if([self.selectedBathroom totalNumber] != 0)
        {
            thumbsUpPercent = (((float)[self.selectedBathroom upNumber])/[self.selectedBathroom totalNumber])*100;
        }
        self.selectedBathroomAnnotation.subtitle = [NSString stringWithFormat:@"Thumbs Up: %.0f%%", thumbsUpPercent];
    }
    if (!self.firstLoad) {
        [self centerView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//MKMapViewDelegate Function
//Add the info icon to annotations
- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation{
    MKAnnotationView *view = nil;
    if(annotation != self.map.userLocation){
        view = (MKPinAnnotationView *)[self.map dequeueReusableAnnotationViewWithIdentifier:@"identifier"];
        if(nil == view) {
            view=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"identifier"];
            UIButton *btnViewVenue = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            view.rightCalloutAccessoryView=btnViewVenue;
            view.enabled = YES;
            view.canShowCallout = YES;
            view.multipleTouchEnabled = NO;
        }
        else
        {
            view.annotation = annotation;
        }
    }
    return view;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    id <MKAnnotation> annotation = [view annotation];
    // Set the selected annotation
    self.selectedBathroomAnnotation = annotation;
    
    testLocationViewController *locationView = [self.storyboard instantiateViewControllerWithIdentifier:@"test"];
    NSMutableArray *array = [[Globals gloablArray] getArray];
    for(int i=0;i<array.count;i++)
    {
        if([[[array objectAtIndex:i] getName] isEqualToString:[annotation title]])
        {
            locationView.bathroom = [array objectAtIndex:i];
            
            // Set the selected bathroom and annotation
            self.selectedBathroom = [array objectAtIndex:i];
            break;
        }
    }
    [self.navigationController pushViewController:locationView animated:YES];
}

// Map moves (dragged) into another region
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"Map Moved");
    // add the bathrooms in the region to the map
    // Does not run if it was the first load because the
    // region is the entire world
    if(!self.firstLoad)
    {
        [self addBathroomsToMap:mapView.region];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if(self.firstLoad)
    {
        NSLog(@"MapView");
        [self centerView];
        self.firstLoad=FALSE;
    }
}

-(void) centerView {
    // This is needed so the map does not go back to
    // the user's location after clicking a bathroom
    if(self.firstLoad)
    {
        NSLog(@"Center View");
        [[Globals gloablArray] clearArray];
        NSMutableArray *array = [[Globals gloablArray] getArray];
        double latitude = [[self.map userLocation] coordinate].latitude;
        double longitude = [[self.map userLocation] coordinate].longitude;
        
        // Make data to send to the server
        NSMutableDictionary *getLocationData = [[NSMutableDictionary alloc]init];
        [getLocationData setObject:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
        [getLocationData setObject:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
        [getLocationData setObject:@"getLocation" forKey:@"function"];
        NSData *t = [Globals accessServer:getLocationData needResponse:TRUE];
        NSString *tempString = [[NSString alloc]initWithData:t encoding:NSUTF8StringEncoding];
        NSLog(@"Data Length: %d String: %d", [t length], [tempString length]);
        
        if([tempString length] != 0)
        {
            [Globals parseJsonFrom:t intoArray:array];
            
            CLLocationCoordinate2D zoomLocation = _map.userLocation.coordinate;
            //if we are unable to read userLocation, let the updateUserLocation callback
            //continue to get called
            if ( zoomLocation.latitude == 0 && zoomLocation.longitude == 0 )
            {
                self.firstLoad = TRUE;
            }
            // 2
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1*METERS_PER_MILE, 1*METERS_PER_MILE);
            // 3
            [_map setRegion:viewRegion animated:YES];
            // add the bathrooms around the user to the map
            [self addBathroomsToMap:viewRegion];
        }
        else // an error occured
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error Occurred" message:@"An error occured when receiving data from the server. The app will try again." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert setTag:0];
            [alert show];
        }
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView tag] == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)addBathroomsToMap:(MKCoordinateRegion)region
{
    NSMutableArray *array = [[Globals gloablArray] getArray];
    for(int i=0;i<array.count;i++)
    {
        Bathroom *tempBathroom =[array objectAtIndex:i];
        CLLocationCoordinate2D tempLocation = [[tempBathroom getLocation] coordinate];
        if([self inRegion:region location:tempLocation])
        {
            float thumbsUpPercent = 0;
            if([tempBathroom totalNumber] != 0)
            {
                thumbsUpPercent = (((float)[tempBathroom upNumber])/[tempBathroom totalNumber])*100;
            }
            NSLog([tempBathroom getName]);
            MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
            point.coordinate = tempLocation;
            point.title = [tempBathroom getName];
            point.subtitle = [NSString stringWithFormat:@"Thumbs Up: %.0f%%", thumbsUpPercent];
            [self.map addAnnotation:point];
        }
    }
}

-(BOOL)inRegion:(MKCoordinateRegion)region location:(CLLocationCoordinate2D)location
{
    CLLocationCoordinate2D center   = region.center;
    CLLocationCoordinate2D northWestCorner, southEastCorner;
    
    northWestCorner.latitude  = center.latitude  - (region.span.latitudeDelta  / 2.0);
    northWestCorner.longitude = center.longitude - (region.span.longitudeDelta / 2.0);
    southEastCorner.latitude  = center.latitude  + (region.span.latitudeDelta  / 2.0);
    southEastCorner.longitude = center.longitude + (region.span.longitudeDelta / 2.0);
    
    if (
        location.latitude  >= northWestCorner.latitude &&
        location.latitude  <= southEastCorner.latitude &&
        
        location.longitude >= northWestCorner.longitude &&
        location.longitude <= southEastCorner.longitude
        )
    {
        // User location (location) in the region - OK :-)
        return TRUE;
    }else {
        
        // User location (location) out of the region - NOT ok :-(
        return FALSE;
    }
}

@end
