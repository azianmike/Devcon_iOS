//
//  AppDelegate.m
//  Poopify
//
//  Created by Ian Eckles on 11/3/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import "AppDelegate.h"
#import "Globals.h"
#import "Bathroom.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    CLLocation *unionLoc = [[CLLocation alloc]initWithLatitude:40.109785 longitude:-88.227243];
    Bathroom *illiniUnion = [[Bathroom alloc] initWithName:@"Illini Union" Location:unionLoc];
    illiniUnion.totalNumber = 10;
    illiniUnion.upNumber = 8;
    illiniUnion.downNumber = 2;
    CLLocation *siebelLoc = [[CLLocation alloc]initWithLatitude:40.113797 longitude:-88.224884];
    Bathroom *siebel = [[Bathroom alloc]initWithName:@"Siebel Center" Location:siebelLoc];
    siebel.totalNumber = 11;
    siebel.upNumber = 5;
    siebel.downNumber = 6;
    CLLocation *ikeLoc = [[CLLocation alloc]initWithLatitude:40.103938 longitude:-88.235263];
    Bathroom *ike = [[Bathroom alloc]initWithName:@"Ike" Location:ikeLoc];
    NSMutableArray *array = [[Globals gloablArray] getArray];
    [array addObject:illiniUnion];
    [array addObject:siebel];
    [array addObject:ike];
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
