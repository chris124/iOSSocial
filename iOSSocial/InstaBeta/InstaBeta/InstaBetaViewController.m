//
//  InstaBetaViewController.m
//  InstaBeta
//
//  Created by Christopher White on 7/26/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "InstaBetaViewController.h"
#import "iOSSocialLocalUser.h"
#import "iOSSocialServicesStore.h"
#import "iOSSServicesViewController.h"

@interface InstaBetaViewController () 

@property(nonatomic, retain)    id<iOSSocialLocalUserProtocol> localUser;

@end

@implementation InstaBetaViewController
@synthesize actionButton;

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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setActionButton:nil];
    [self setActionButton:nil];
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

    [iossServicesViewController presentModallyFromViewController:self 
                                              withAccountHandler:^(id<iOSSocialLocalUserProtocol> theLocalUser) {
                                                  [[iOSSocialServicesStore sharedServiceStore] unregisterAccount:theLocalUser];
                                                  [theLocalUser logout];
                                                  theLocalUser = nil;
                                                  [iossServicesViewController refreshUI];
                                              }
                                     withServiceConnectedHandler:^(id<iOSSocialLocalUserProtocol> theLocalUser) {
                                             [[iOSSocialServicesStore sharedServiceStore] registerAccount:theLocalUser];
                                             [iossServicesViewController refreshUI];

                                     }  
                                           withCompletionHandler:^{
                                               [self dismissModalViewControllerAnimated:YES];
                                           }
     ];
}

- (IBAction)actionButtonPressed:(id)sender 
{
    if (!self.localUser) {
        self.localUser = [[iOSSocialServicesStore sharedServiceStore] defaultAccount];
    }
    
    //cwnote: update readme for iOSSocial to show this use case
    if (![self.localUser isAuthenticated] ) {
        [self.localUser authenticateFromViewController:self 
                                 withCompletionHandler:^(NSError *error){
                                     if (error) {
                                     } else {
                                         [[iOSSocialServicesStore sharedServiceStore] registerAccount:self.localUser];
                                     }
                                 }];
    } else {
        [[iOSSocialServicesStore sharedServiceStore] unregisterAccount:self.localUser];
        [self.localUser logout];
        self.localUser = nil;
    }
}

@end
