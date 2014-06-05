//
//  ListViewController.m
//  Poopify
//
//  Created by Ian Eckles on 11/3/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import "ListViewController.h"
#define METERS_PER_MILE 1609.344

@interface ListViewController ()

@end

@implementation ListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.retryNumber = 0;
    
    self.bathroomLocations = [[NSMutableArray alloc]init];
    [self startSignificantChangeUpdates];
    NSLog(@"Done Loading tableView");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.bathroomLocations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [[self.bathroomLocations objectAtIndex:indexPath.row] buildingName];
    Bathroom *tempBathroom = [self.bathroomLocations objectAtIndex:indexPath.row];
    UILabel *up = (UILabel *)[cell viewWithTag:100];
    UILabel *down = (UILabel *)[cell viewWithTag:101];
    UILabel *name = (UILabel *)[cell viewWithTag:102];
    name.text = [tempBathroom buildingName];
    down.text = @"%i", [tempBathroom downNumber];
    up.text = @"%i", [tempBathroom upNumber];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Cell: %i", indexPath.row);
    testLocationViewController *locationView = [self.storyboard instantiateViewControllerWithIdentifier:@"test"];
    locationView.bathroom = [self.bathroomLocations objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:locationView animated:YES];
}

-(BOOL)inRegion:(MKCoordinateRegion)region location:(CLLocationCoordinate2D)location
{
    CLLocationCoordinate2D center   = region.center;
    CLLocationCoordinate2D northWestCorner, southEastCorner;
    
    northWestCorner.latitude  = center.latitude  - (region.span.latitudeDelta  / 2.0);
    northWestCorner.longitude = center.longitude - (region.span.longitudeDelta / 2.0);
    southEastCorner.latitude  = center.latitude  + (region.span.latitudeDelta  / 2.0);
    southEastCorner.longitude = center.longitude + (region.span.longitudeDelta / 2.0);
    
    if (
        location.latitude  >= northWestCorner.latitude &&
        location.latitude  <= southEastCorner.latitude &&
        
        location.longitude >= northWestCorner.longitude &&
        location.longitude <= southEastCorner.longitude
        )
    {
        // User location (location) in the region - OK :-)
        return TRUE;
    }else {
        
        // User location (location) out of the region - NOT ok :-(
        return FALSE;
    }
}


- (void)startSignificantChangeUpdates
{
    if ([CLLocationManager locationServicesEnabled])
    {
        if (!self.locationManager)
            self.locationManager = [[CLLocationManager alloc] init];
        
        self.locationManager.delegate = self;
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
}

- (void)stopSignificantChangesUpdates
{
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    [self loadFromDatabase:location.coordinate.latitude longitude:location.coordinate.longitude];
    self.currentLocation = location;
    [self stopSignificantChangesUpdates];
}

-(void)loadFromDatabase:(double)latitude longitude:(double)longitude
{
    [self.view addSubview:[[UILoadingView alloc] initWithFrame:self.view.bounds]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Make data to send to the server
        NSMutableDictionary *getLocationData = [[NSMutableDictionary alloc]init];
        [getLocationData setObject:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
        [getLocationData setObject:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
        [getLocationData setObject:@"getLocation" forKey:@"function"];
        NSData *t = [Globals accessServer:getLocationData needResponse:TRUE];
        NSString *tempString = [[NSString alloc]initWithData:t encoding:NSUTF8StringEncoding];
        if([tempString length] != 0)
        {
            [Globals parseJsonFrom:t intoArray:self.bathroomLocations];
            
            [self performSelectorOnMainThread:@selector(doneLoadingLocations) withObject:nil waitUntilDone:NO];
        }
        else //error occured
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error Occurred" message:@"An error occured when receiving data from the server. Please try again." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert setTag:0];
            [alert show];
        }
    });
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView tag] == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)doneLoadingLocations
{
    [[self.view.subviews lastObject] removeFromSuperview];
    [self.tableView reloadData];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
