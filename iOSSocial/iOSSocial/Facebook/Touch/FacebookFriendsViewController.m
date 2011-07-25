//
//  FacebookFriendsViewController.m
//  MadRaces
//
//  Created by Christopher White on 7/5/11.
//  Copyright 2011 Betaworks. All rights reserved.
//

#import "FacebookFriendsViewController.h"
#import "LocalFacebookUser.h"
#import "FacebookPhotoAlbum.h"
#import "Three20/Three20.h"

@implementation FacebookFriendsViewController

@synthesize friends;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [friends release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [super viewDidLoad];
    self.navigationItem.title = @"Friends";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    [[LocalFacebookUser localFacebookUser] loadPhotoAlbumsWithCompletionHandler:^(NSArray *albums, NSError *error) {
        
        if (!error) {
            if (!error) {
                self.friends = albums;
                [self.tableView reloadData]; 
            }
        }
        
    }];
    
    /*
    [[LocalFacebookUser localFacebookUser] loadFriendsWithCompletionHandler:^(NSArray *friendIDs, NSError *error) {
        
        if (!error) {
            //have to fetch the user info for each one
            [[LocalFacebookUser localFacebookUser] loadUsersForIdentifiers:friendIDs withCompletionHandler:^(NSArray *users, NSError *error){
                //the returned array is an array of FacebookUser objects. copy the array of users.
                self.friends = users;
                [self.tableView reloadData]; 
            }];
        }
        
    }];*/
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    FacebookPhotoAlbum *album = [self.friends objectAtIndex:[indexPath row]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", album.name, album.description];
    
    /*
    FacebookUser *user = [self.friends objectAtIndex:[indexPath row]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ (%@)", user.firstName, user.lastName, user.alias];
    [user loadPhotoWithCompletionHandler:^(UIImage *photo, NSError *error) {
        cell.imageView.image = photo;
        [cell setNeedsLayout];
    }];
    */
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //use three20 to show the photos
    FacebookPhotoAlbum *album = [self.friends objectAtIndex:[indexPath row]];
    TTPhotoViewController *ttPhotoViewController = [[TTPhotoViewController alloc] initWithPhotoSource:album];
    [self.navigationController pushViewController:ttPhotoViewController animated:YES];
    [ttPhotoViewController release];
}

@end
