//
//  InstaBetaViewController.m
//  InstaBeta
//
//  Created by Christopher White on 7/26/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "InstaBetaViewController.h"
#import "LocalTwitterUser.h"
#import "LocalFoursquareUser.h"
#import "iOSServicesDataSource.h"
#import "iOSSService.h"

@implementation InstaBetaViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

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
    NSMutableArray *services = [NSMutableArray array];
    
    NSMutableDictionary *serviceDictionary = [NSMutableDictionary dictionary];
    [serviceDictionary setObject:@"Twitter" forKey:@"name"];
    NSURL *photoURL = [[NSBundle mainBundle] URLForResource:@"twitter-logo" withExtension:@"png"];
    if (photoURL) {
        [serviceDictionary setObject:photoURL forKey:@"photoURL"];
    }
    [serviceDictionary setObject:[LocalTwitterUser localTwitterUser] forKey:@"localUser"];
    
    iOSSService *twitter = [[iOSSService alloc] initWithDictionary:serviceDictionary];
    [services addObject:twitter];
    
    [serviceDictionary removeAllObjects];
    [serviceDictionary setObject:@"Foursquare" forKey:@"name"];
    photoURL = [[NSBundle mainBundle] URLForResource:@"foursquare_trans" withExtension:@"png"];
    if (photoURL) {
        [serviceDictionary setObject:photoURL forKey:@"photoURL"];
    }
    [serviceDictionary setObject:[LocalFoursquareUser localFoursquareUser] forKey:@"localUser"];
    
    iOSSService *foursquare = [[iOSSService alloc] initWithDictionary:serviceDictionary];
    [services addObject:foursquare];
    
    iOSServicesDataSource *dataSource = [[iOSServicesDataSource alloc] initWithSources:services];
    dataSource.displayDoneButton = YES;
    dataSource.message = @"Meh";
    
    iOSSServicesViewController *iossServicesViewController = [[iOSSServicesViewController alloc] initWithDataSource:dataSource];
    iossServicesViewController.serviceControllerDelegate = self;
    [self presentModalViewController:iossServicesViewController animated:YES];
}

@end
