//
//  AddNewLocationViewController.h
//  Poopify
//
//  Created by Ian Eckles on 11/3/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Globals.h"

@interface AddNewLocationViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet UITextField *buildingName;
@property (nonatomic, strong) IBOutlet UITextView *description;
@property (nonatomic, weak) IBOutlet MKMapView *map;
@property (nonatomic, strong) IBOutlet UIButton *upButton;
@property (nonatomic, strong) IBOutlet UIButton *downButton;
@property BOOL upPressed;
@property BOOL downPressed;
@property BOOL firstLoad;


- (void)keyboardDidShow;
-(void)keyboardDidHide;
-(IBAction)upButtonClicked:(id)sender;
-(IBAction)downButtonClicked:(id)sender;
-(IBAction)submitNewLocation:(id)sender;
@end
