//
//  Globals.h
//  Poopify
//
//  Created by Ian Eckles on 11/4/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import "Bathroom.h"
#import "Comment.h"
#import "Picture.h"

@interface Globals : NSObject
{
    NSMutableArray * myGlobalArray;
}
@property (nonatomic, strong) NSMutableArray *myGlobalArray;
@property (nonatomic, strong) CLLocationManager *locationManager;
+(Globals *)gloablArray;
+(NSString *)hashed_string:(NSString *)input;
-(NSMutableArray*)getArray;
-(void)clearArray;
+(NSData *)accessServer:(NSMutableDictionary *) dic needResponse:(BOOL) response;
+(void)parseJsonFrom:(NSData *)t intoArray:(NSMutableArray *) array;
+(BOOL)inArea:(CLLocation *)bathroomLocation currentLocation:(CLLocation *)current;
@end
