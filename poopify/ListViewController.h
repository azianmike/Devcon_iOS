//
//  ListViewController.h
//  Poopify
//
//  Created by Ian Eckles on 11/3/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Comment.h"
#import "Globals.h"
#import "UILoadingView.h"
#import "testLocationViewController.h"

@interface ListViewController : UITableViewController <CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableArray *bathroomLocations;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property int retryNumber;
@property (nonatomic, strong) CLLocation *currentLocation;


-(BOOL)inRegion:(MKCoordinateRegion)region location:(CLLocationCoordinate2D)location;
-(void)loadFromDatabase:(double)latitude longitude:(double)longitude;
@end
