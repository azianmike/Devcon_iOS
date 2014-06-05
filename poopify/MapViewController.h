//
//  MapViewController.h
//  Poopify
//
//  Created by Ian Eckles on 11/3/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Globals.h"
#import "testLocationViewController.h"

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *map;
@property BOOL firstLoad;
@property MKPointAnnotation *selectedBathroomAnnotation;
@property Bathroom *selectedBathroom;

- (void) centerView;
-(void)addBathroomsToMap:(MKCoordinateRegion)region;
-(BOOL)inRegion:(MKCoordinateRegion)region location:(CLLocationCoordinate2D)location;
@end
