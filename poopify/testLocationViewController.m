//
//  testLocationViewController.m
//  Poopify
//
//  Created by Ian Eckles on 11/14/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import "testLocationViewController.h"
#define METERS_PER_MILE 1609.344
#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
const int HASNOTVOTED1 = -1;
const int VOTEDUP1 = 1;
const int VOTEDDOWN1 = 0;

@interface testLocationViewController ()

@end

@implementation testLocationViewController

-(id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.directions =
    [[UIBarButtonItem alloc] initWithTitle:@"Get Directions" style:UIBarButtonItemStyleBordered target:self action:@selector( openDirections )];
    self.navigationItem.rightBarButtonItem = self.directions;
    
    self.array = self.bathroom.comments;
    
    self.alreadyVoted = HASNOTVOTED1;
    // Checks if the user has already voted
    [self getVotedData];
    
    self.upPressed = FALSE;
    self.downPressed = FALSE;
    self.buildingName.text = self.bathroom.buildingName;
    [self updateVotingNumbers];
    
    // Add point on map
    MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
    point.coordinate = [[self.bathroom getLocation] coordinate];
    point.title = self.bathroom.buildingName;
    [self.map addAnnotation:point];
    
    // Go to annotation
    CLLocationCoordinate2D zoomLocation = point.coordinate;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, .5*METERS_PER_MILE, .5*METERS_PER_MILE);
    [self.map setRegion:viewRegion animated:YES];
    
    // Set the view to the header so that it appears above the comments
    [self.tableView setTableHeaderView:self.headerView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

-(void)updateVotingNumbers
{
    float upPercent = 0;
    float downPercent = 0;
    if([self.bathroom totalNumber]!=0)
    {
        upPercent = (float)[self.bathroom upNumber]/[self.bathroom totalNumber]*100;
        downPercent = (float)[self.bathroom downNumber]/[self.bathroom totalNumber]*100;
    }
    self.upNumber.text = [NSString stringWithFormat:@"%.0f%%", upPercent ];
    self.downNumber.text = [NSString stringWithFormat:@"%.0f%%", downPercent];
}

-(void)openDirections
{
    NSLog(@"Open Directions");
    NSString *url = [NSString stringWithFormat:@"comgooglemaps://?daddr=%f,%f&directionsmode=walking", self.bathroom.location.coordinate.latitude, self.bathroom.location.coordinate.longitude];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

-(void)getVotedData
{
    int user_id = (int)[[NSUserDefaults standardUserDefaults]integerForKey:@"user_id"];
    if(user_id != 0)
    {
        // do this in a background thread so that the GUI does not freeze
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            int user_id = (int)[[NSUserDefaults standardUserDefaults]integerForKey:@"user_id"];
            int location_id = [self.bathroom location_id];
            
            // Make data to send to the server
            NSMutableDictionary *getThumbData = [[NSMutableDictionary alloc]init];
            [getThumbData setObject:@"getThumb" forKey:@"function"];
            [getThumbData setObject:[NSString stringWithFormat:@"%d", user_id] forKey:@"user_id"];
            [getThumbData setObject:[NSString stringWithFormat:@"%d", location_id] forKey:@"location_id"];
            
            NSData *t = [Globals accessServer:getThumbData needResponse:TRUE];
            int returnValue = [[[NSString alloc] initWithData:t encoding:NSUTF8StringEncoding] intValue];
            
            [self setAlreadyVoted:returnValue];
            
            // if the user has voted, set the bool to the correct value and make
            // the correct thumb blue
            if(self.alreadyVoted == VOTEDUP1)
            {
                [self performSelectorOnMainThread:@selector(upButtonClicked:) withObject:nil waitUntilDone:NO];
            }
            else if(self.alreadyVoted == VOTEDDOWN1)
            {
                [self performSelectorOnMainThread:@selector(downButtonClicked:) withObject:nil waitUntilDone:NO];
            }
        });
    }
}

-(void)sendRatingToServer
{
    // Run the code to send the rating to the database
    int user_id = [[NSUserDefaults standardUserDefaults]integerForKey:@"user_id"];
    
    // Make data to send to the server
    NSMutableDictionary *ratingData = [[NSMutableDictionary alloc]init];
    [ratingData setObject:@"setThumb" forKey:@"function"];
    [ratingData setObject:[NSString stringWithFormat:@"%d", user_id] forKey:@"user_id"];
    [ratingData setObject:[NSString stringWithFormat:@"%d", self.bathroom.location_id] forKey:@"location_id"];
    
    if(self.downPressed == TRUE)
    {
        [ratingData setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"thumbsUp"];
        [Globals accessServer:ratingData needResponse:FALSE];
    }
    else if(self.upPressed == TRUE)
    {
        [ratingData setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"thumbsUp"];
        [Globals accessServer:ratingData needResponse:FALSE];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound)
    {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        
        // Check to see if they voted firstly
        if(self.upPressed || self.downPressed)
        {
            if(self.upPressed && self.alreadyVoted != 1)
            {
                [self sendRatingToServer];
            }
            if(self.downPressed && self.alreadyVoted != 0)
            {
                [self sendRatingToServer];
            }
        }
    }
    [super viewWillDisappear:animated];
}

// Change the colors of the buttons when pressed
-(IBAction)upButtonClicked:(id)sender
{
    int user_id = (int)[[NSUserDefaults standardUserDefaults]integerForKey:@"user_id"];
    if(user_id != 0)
    {
        if(self.upPressed) // Up button already selected
        {
            // Do nothing
        }
        else if(self.downPressed)
        {
            [self.downButton setImage:[UIImage imageNamed:@"thumbsDown.png"] forState:UIControlStateNormal];
            [self.upButton setImage:[UIImage imageNamed:@"thumbsUpBlue.png"] forState:UIControlStateNormal];
            self.upPressed = TRUE;
            self.downPressed = FALSE;
            
            // Change the bathroom stats
            self.bathroom.upNumber++;
            self.bathroom.downNumber--;
            
            // Update UI stats
            [self updateVotingNumbers];
        }
        else
        {
            [self.upButton setImage:[UIImage imageNamed:@"thumbsUpBlue.png"] forState:UIControlStateNormal];
            self.upPressed = TRUE;
            if(sender != nil)
            {
                // Change the bathroom stats
                self.bathroom.upNumber++;
                self.bathroom.totalNumber++;
                
                // Update UI stats
                [self updateVotingNumbers];
            }
        }
    }
    else
    {
        UIAlertView *notLoggedIn = [[UIAlertView alloc]initWithTitle:@"Must Be Logged In" message:@"Please login or create and account to rate bathrooms" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [notLoggedIn show];
    }
}

// Change the colors of the buttons when pressed
-(IBAction)downButtonClicked:(id)sender
{
    // Check if the user is logged in
    int user_id = (int)[[NSUserDefaults standardUserDefaults]integerForKey:@"user_id"];
    if(user_id != 0)
    {
        if(self.downPressed)
        {
            // Do nothing
        }
        else if(self.upPressed)
        {
            [self.downButton setImage:[UIImage imageNamed:@"thumbsDownBlue.png"] forState:UIControlStateNormal];
            [self.upButton setImage:[UIImage imageNamed:@"thumbsUp.png"] forState:UIControlStateNormal];
            self.downPressed = TRUE;
            self.upPressed = FALSE;
            
            // Change the bathroom stats
            self.bathroom.upNumber--;
            self.bathroom.downNumber++;
            
            // Update UI stats
            [self updateVotingNumbers];
        }
        else
        {
            [self.downButton setImage:[UIImage imageNamed:@"thumbsDownBlue.png"] forState:UIControlStateNormal];
            self.downPressed = TRUE;
            if(sender != nil)
            {
                // Change the bathroom stats
                self.bathroom.downNumber++;
                self.bathroom.totalNumber++;
                
                // Update UI stats
                [self updateVotingNumbers];
            }
        }
    }
    else
    {
        UIAlertView *notLoggedIn = [[UIAlertView alloc]initWithTitle:@"Must Be Logged In" message:@"Please login or create and account to rate bathrooms" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [notLoggedIn show];
    }
}

//Add comment button clicked
-(IBAction)addComment:(id)sender
{
    int user_id = (int)[[NSUserDefaults standardUserDefaults]integerForKey:@"user_id"];
    if(user_id != 0)
    {
        if([Globals inArea:self.bathroom.location currentLocation:self.map.userLocation.location])
        {
            AddCommentViewController *addComment = [self.storyboard instantiateViewControllerWithIdentifier:@"AddCommentViewController"];
            addComment.bathroom = self.bathroom;
            [self.navigationController pushViewController:addComment animated:YES];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"You must be at the location if you want to add a comment" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
        }
    }
    else // Not logged in so they can't comment/review
    {
        UIAlertView *notLoggedIn = [[UIAlertView alloc]initWithTitle:@"Must Be Logged In" message:@"Please login or create and account to comment on bathrooms" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [notLoggedIn show];
    }
}

-(IBAction)viewPhotos:(id)sender
{
    int user_id = (int)[[NSUserDefaults standardUserDefaults]integerForKey:@"user_id"];
    if(user_id != 0)
    {
        PictureViewController *pictureView = [self.storyboard instantiateViewControllerWithIdentifier:@"PictureViewController"];
        pictureView.bathroom = self.bathroom;
        pictureView.currentLocation = self.map.userLocation.location;
        [self.navigationController pushViewController:pictureView animated:YES];
    }
    else // Not logged in so they can't comment/review
    {
        UIAlertView *notLoggedIn = [[UIAlertView alloc]initWithTitle:@"Must Be Logged In" message:@"Please login or create and account to add pictures to bathrooms" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [notLoggedIn show];
    }
}

-(void)didReceiveMemoryWarning
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
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    /*UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    cell.textLabel.text = [[self.array objectAtIndex:indexPath.row] comment];*/
    CommentTableCell *cell = (CommentTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.user.text = [NSString stringWithFormat:@"User: %d",[[self.array objectAtIndex:indexPath.row] user_id]];
    cell.comment.text = [[self.array objectAtIndex:indexPath.row] comment];
    cell.comment.userInteractionEnabled = NO;

    CGFloat height = cell.comment.contentSize.height;
    // Change the size of the cell
    CGRect frame = cell.frame;
    frame.size.height = height+63;
    cell.frame = frame;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 63 + height of textview
    NSString *text = [[self.array objectAtIndex:indexPath.row] comment];
    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = MAX(size.height, 44.0f);
    
    return height + (CELL_CONTENT_MARGIN * 2)+55;
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
