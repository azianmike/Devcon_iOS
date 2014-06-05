//
//  PictureViewController.h
//  Poopify
//
//  Created by Ian Eckles on 11/18/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bathroom.h"
#import "Picture.h"
#import "Globals.h"
#import "UILoadingView.h"
#import "UISendingView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface PictureViewController : UICollectionViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) Bathroom *bathroom;
@property (nonatomic, strong) CLLocation *currentLocation;

@end
