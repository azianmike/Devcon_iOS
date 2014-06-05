//
//  Globals.m
//  Poopify
//
//  Created by Ian Eckles on 11/4/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import "Globals.h"

@implementation Globals
@synthesize myGlobalArray;

+(Globals *)gloablArray
{
    static Globals *global = nil;
    if(!global)
    {
        global = [[[self class]alloc]init];
        global.myGlobalArray = [[NSMutableArray alloc]init];
    }
    return global;
}
-(NSMutableArray*)getArray
{
    return myGlobalArray;
}

-(void)clearArray
{
    if([myGlobalArray count])
    {
        [myGlobalArray removeAllObjects];
    }
}

// Hashing the password in sha256
// Cite: http://www.raywenderlich.com/6475/basic-security-in-ios-5-tutorial-part-1
+(NSString *)hashed_string:(NSString *)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    // This is an iOS5-specific method.
    // It takes in the data, how much data, and then output format, which in this case is an int array.
    CC_SHA256(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

+(NSData *)accessServer:(NSMutableDictionary *) dic needResponse:(BOOL) response
{
    // Conect to the server
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStringRef remoteHost = CFSTR("ec2-54-201-41-167.us-west-2.compute.amazonaws.com");
    CFStreamCreatePairWithSocketToHost(NULL, remoteHost, 5687, &readStream, &writeStream);
    CFWriteStreamOpen(writeStream);
    CFReadStreamOpen(readStream);
    
    // send data
    NSData *json = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *jsonString = [[NSString alloc]initWithData:json encoding:NSUTF8StringEncoding];
    jsonString = [NSString stringWithFormat:@"%@%@", jsonString, @"\r\n\r\n"];
    UInt8 *writeBuf = (UInt8 *)[jsonString UTF8String];
    int writtenBytes = 0;
    int bytesToSend = (int)[jsonString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    while(writtenBytes < bytesToSend)
    {
        writtenBytes += CFWriteStreamWrite(writeStream, writeBuf, bytesToSend-writtenBytes);
    }
    NSLog(@"Done sending, Sent :%d Total: %d",writtenBytes,bytesToSend);
    CFWriteStreamClose(writeStream);
    if(response)
    {
        // get the return data
        uint8_t readData[10000];
        int readBytes = 1;
        int totalRead = 0;
        while(readBytes > 0)
        {
            readBytes = (int)CFReadStreamRead(readStream, readData, 10000);
            totalRead += readBytes;
        }
        CFReadStreamClose(readStream);
        return [[NSData alloc]initWithBytes:readData length:totalRead];
    }
    else
    {
        CFReadStreamClose(readStream);
        return nil;
    }
}

+(void)parseJsonFrom:(NSData *)t intoArray:(NSMutableArray *)array
{
    NSDictionary *location = [[NSJSONSerialization JSONObjectWithData:t options:0 error:nil] objectForKey:@"locations"];
    for(NSDictionary *tempData in location) {
        NSDictionary *comments = [tempData objectForKey:@"commentArray"];
        CLLocationDegrees latitude = [[tempData objectForKey:@"latitude"] doubleValue];
        CLLocationDegrees longitude = [[tempData objectForKey:@"longitude"] doubleValue];
        CLLocation *loc = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
        Bathroom *tempBathroom = [[Bathroom alloc]initWithName:[tempData objectForKey:@"location_name"] Location:loc upNumber:[[tempData objectForKey:@"thumbsUp"] intValue] downNumber:[[tempData objectForKey:@"thumbsDown"] intValue] locationID: [[tempData objectForKey:@"location_id"] intValue]];
        NSMutableArray *commentsArray = [[NSMutableArray alloc]init];
        for(NSDictionary *tempComment in comments)
        {
            Comment *com = [[Comment alloc]init];
            com.user_id = [[tempComment objectForKey:@"user_id"] intValue];
            com.comment = [tempComment objectForKey:@"comment"];
            [commentsArray addObject:com];
        }
        tempBathroom.comments = commentsArray;
        [array addObject:tempBathroom];
    }
}

+(BOOL)inArea:(CLLocation *)bathroomLocation currentLocation:(CLLocation *)current
{
    if(fabs(bathroomLocation.coordinate.latitude-current.coordinate.latitude) <=.00100 && fabs(bathroomLocation.coordinate.longitude-current.coordinate.longitude) <=.00100)
    {
        return TRUE;
    }
    return FALSE;
}

@end
