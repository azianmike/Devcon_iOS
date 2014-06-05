//
//  testLocationViewController.h
//  Poopify
//
//  Created by Ian Eckles on 11/14/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Bathroom.h"
#import "Comment.h"
#import "CommentTableCell.h"
#import "AddCommentViewController.h"
#import "PictureViewController.h"
#import "Globals.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface testLocationViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property NSMutableArray *array;
@property (nonatomic, strong) IBOutlet UILabel *buildingName;
@property (nonatomic, strong) IBOutlet UIButton *upButton;
@property (nonatomic, strong) IBOutlet UIButton *downButton;
@property (nonatomic, strong) IBOutlet UILabel *downNumber;
@property (nonatomic, strong) IBOutlet UILabel *upNumber;
@property (nonatomic, strong) IBOutlet MKMapView *map;
@property BOOL upPressed;
@property BOOL downPressed;
@property int alreadyVoted;
@property (nonatomic, strong) Bathroom *bathroom;
//@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) UIBarButtonItem *directions;

-(IBAction)upButtonClicked:(id)sender;
-(IBAction)downButtonClicked:(id)sender;
-(void)getVotedData;
-(IBAction)addComment:(id)sender;
-(IBAction)viewPhotos:(id)sender;
@end
