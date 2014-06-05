//
//  Bathroom.m
//  Poopify
//
//  Created by Ian Eckles on 11/4/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import "Bathroom.h"

@implementation Bathroom

-(id)initWithName:(NSString*)name Location:(CLLocation*)loc
{
    self.buildingName = name;
    self.location = loc;
    self.upNumber = 0;
    self.downNumber = 0;
    self.totalNumber = 0;
    self.comments = [[NSMutableArray alloc]init];
    self.pictures = [[NSMutableArray alloc]init];
    return(self);
}

-(id)initWithName:(NSString*)name Location:(CLLocation*)loc upNumber:(int) up downNumber: (int) down locationID: (int)ID
{
    self.buildingName = name;
    self.location = loc;
    self.upNumber = up;
    self.downNumber = down;
    self.totalNumber = up+down;
    self.location_id = ID;
    self.comments = [[NSMutableArray alloc]init];
    self.pictures = [[NSMutableArray alloc]init];
    return(self);
}

-(void)addComments:(NSMutableArray *)comment
{
    for(int i = 0;i<comment.count;i++)
    {
        [self.comments addObject:[comment objectAtIndex:i]];
    }
}

-(CLLocation*)getLocation
{
    return self.location;
}

-(NSString *)getName
{
    return self.buildingName;
}

@end
