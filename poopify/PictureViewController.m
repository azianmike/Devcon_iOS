//
//  PictureViewController.m
//  Poopify
//
//  Created by Ian Eckles on 11/18/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import "PictureViewController.h"

@interface PictureViewController ()

@end

@implementation PictureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)getURLs
{
    [self.view addSubview:[[UILoadingView alloc] initWithFrame:self.view.bounds]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Grab the urls from the server
        NSMutableDictionary *getPictureData = [[NSMutableDictionary alloc]init];
        [getPictureData setObject:[NSString stringWithFormat:@"%d", self.bathroom.location_id] forKey:@"location_id"];
        [getPictureData setObject:@"getPicture" forKey:@"function"];
        NSData *t = [Globals accessServer:getPictureData needResponse:TRUE];
        NSDictionary *pictures = [[NSJSONSerialization JSONObjectWithData:t options:0 error:nil] objectForKey:@"pictures"];
        for(NSDictionary *tempData in pictures)
        {
            [self.bathroom.pictures addObject:[tempData objectForKey:@"url"]];
        }
        [self performSelectorOnMainThread:@selector(doneLoadingURLs) withObject:nil waitUntilDone:NO];
    });
}

-(void)doneLoadingURLs
{
    [[self.view.subviews lastObject] removeFromSuperview];
    [self.collectionView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Add the plus button for adding a picture
    // Clears picture array for the new data
    [self.bathroom.pictures removeAllObjects];
    NSLog(@"LOL HERE");
    [self getURLs];
    
    UIBarButtonItem *addPic = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"blue_add_small.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(addPhoto:)];
    self.navigationItem.rightBarButtonItem = addPic;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
}

-(IBAction)addPhoto:(id)sender
{
    if([Globals inArea:self.bathroom.location currentLocation:self.currentLocation])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:NULL];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"You must be at the location if you want to add a photo" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
}

// Camera delegate method (adding a picture)
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self.view addSubview:[[UISendingView alloc] initWithFrame:self.view.bounds]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        NSData *data = UIImageJPEGRepresentation(chosenImage, .5);
        NSString *base64 = [[NSString alloc]initWithData:[data base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength] encoding:NSUTF8StringEncoding];
        // Make data to send to the server
        int user_id = [[NSUserDefaults standardUserDefaults]integerForKey:@"user_id"];
        NSMutableDictionary *addPictureData = [[NSMutableDictionary alloc]init];
        [addPictureData setObject:@"addPicture" forKey:@"function"];
        [addPictureData setObject:base64 forKey:@"data"];
        [addPictureData setObject:[NSString stringWithFormat:@"%d",user_id] forKey:@"user_id"];
        [addPictureData setObject:[NSString stringWithFormat:@"%d",self.bathroom.location_id] forKey:@"location_id"];
        NSData *t = [Globals accessServer:addPictureData needResponse:YES];
        NSString * url = [[NSString alloc]initWithData:t encoding:NSUTF8StringEncoding];
        [self.bathroom.pictures addObject:url];

        [self performSelectorOnMainThread:@selector(doneSendingPicture) withObject:nil waitUntilDone:NO];
    });

    //[picker dismissViewControllerAnimated:YES completion:NULL];
    //[self.collectionView reloadData];
}

-(void)doneSendingPicture
{
    [[self.view.subviews lastObject] removeFromSuperview];
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.bathroom.pictures.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *picture = (UIImageView *)[cell viewWithTag:100];
    [picture.layer setBorderColor:[[UIColor blackColor]CGColor]];
    [picture.layer setBorderWidth:2.0];
    [picture setImageWithURL:[NSURL URLWithString:[self.bathroom.pictures objectAtIndex:indexPath.row]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    return cell;
}

@end
