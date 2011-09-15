//
//  InstaBetaViewController.m
//  InstaBeta
//
//  Created by Christopher White on 7/26/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "InstaBetaViewController.h"
#import "iOSSService.h"
#import "iOSSocialLocalUser.h"
#import "iOSSocialServicesStore.h"
#import "LocalFlickrUser.h"
#import "LocalTwitterUser.h"
#import "iOSSServicesViewController.h"

@interface InstaBetaViewController () 

@property(nonatomic, retain)    id<iOSSocialLocalUserProtocol> localUser;

@end

@implementation InstaBetaViewController

@synthesize localUser;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    self.localUser = [[iOSSocialServicesStore sharedServiceStore] defaultAccount];
    
    if (![self.localUser isAuthenticated] ) {
        [self.localUser authenticateFromViewController:self 
                                          withCompletionHandler:^(NSError *error){
                                              if (error) {
                                              } else {
                                              }
                                          }];
    } else {
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)servicesButtonPressed:(id)sender 
{
    iOSSServicesViewController *iossServicesViewController = [[iOSSServicesViewController alloc] init];
    [self presentModalViewController:iossServicesViewController animated:YES];
    
    [iossServicesViewController presentModallyFromViewController:self withCompletionHandler:^{
        //
        [self dismissModalViewControllerAnimated:YES];
    }];
}

- (IBAction)actionButtonPressed:(id)sender 
{
    //cwnote: update readme for iOSSocial to show this use case
    
    LocalTwitterUser *localTwitterUser = (LocalTwitterUser*)[[iOSSocialServicesStore sharedServiceStore] accountWithType:@"Twitter"];
    //[localTwitterUser postTweetWithMedia];
    [localTwitterUser postTweet];
}

- (IBAction)anotheractionButtonPressed:(id)sender 
{
    /*
    UIImagePickerController *picker = [[UIImagePickerController alloc] init]; 
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera; 
    }
    picker.delegate = self; 
    [self presentModalViewController:picker animated:YES];
     */

    LocalFlickrUser *localFlickrUser = (LocalFlickrUser*)[[iOSSocialServicesStore sharedServiceStore] accountWithType:@"Flickr"];
    /*
    [localFlickrUser postPhotoWithCompletionHandler:^(NSString *photoID, NSError *error) {
        //
        if (!error) {
            //get the photo info of the photo with this id
            ////now get the photo info
            [localFlickrUser getInfoForPhotoWithId:photoID andCompletionHandler:^(NSDictionary *photoInfo, NSError *error) {
                //
                NSLog(@"meh");
            }];
            
            [localFlickrUser getUserPhotosWithCompletionHandler:^(NSDictionary *photos, NSError *error) {
                //
                NSLog(@"meh");
            }];
        }
    }];
    */
    [localFlickrUser getUserPhotosWithCompletionHandler:^(NSDictionary *photos, NSError *error) {
        //
        NSLog(@"meh");
    }];
}

@end
