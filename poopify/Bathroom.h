//
//  Bathroom.h
//  Poopify
//
//  Created by Ian Eckles on 11/4/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Bathroom : NSObject

@property NSString *buildingName;
@property CLLocation *location;
@property int upNumber;
@property int downNumber;
@property int totalNumber;
@property int location_id;
@property NSMutableArray *comments;
@property NSMutableArray *pictures;

-(id)initWithName:(NSString*)name Location:(CLLocation*)loc;
-(id)initWithName:(NSString*)name Location:(CLLocation*)loc upNumber:(int) up downNumber: (int) down locationID: (int)ID;
-(void)addcomments:(NSMutableArray *)comment;
-(CLLocation*)getLocation;
-(NSString *)getName;
@end
