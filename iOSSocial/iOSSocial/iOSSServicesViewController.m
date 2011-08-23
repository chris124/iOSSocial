//
//  iOSSServicesViewController.m
//  InstaBeta
//
//  Created by Christopher White on 7/21/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "iOSSServicesViewController.h"
#import "iOSSocial.h"
#import "iOSServicesDataSource.h"
#import "iOSSService.h"
#import "LocalTwitterUser.h"
#import "LocalFoursquareUser.h"

@implementation iOSSServicesViewController

@synthesize serviceControllerDelegate=_serviceControllerDelegate;

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        
        NSMutableArray *services = [NSMutableArray array];
        
        NSMutableDictionary *serviceDictionary = [NSMutableDictionary dictionary];
        [serviceDictionary setObject:@"Instagram" forKey:@"name"];
        NSURL *photoURL = [[NSBundle mainBundle] URLForResource:@"instagram_trans" withExtension:@"png"];
        [serviceDictionary setObject:photoURL forKey:@"photoURL"];
        [serviceDictionary setObject:[LocalInstagramUser localInstagramUser] forKey:@"localUser"];
        
        iOSSService *instagram = [[iOSSService alloc] initWithDictionary:serviceDictionary];
        [services addObject:instagram];
        
        
        [serviceDictionary removeAllObjects];
        [serviceDictionary setObject:@"Twitter" forKey:@"name"];
        photoURL = [[NSBundle mainBundle] URLForResource:@"twitter-logo" withExtension:@"png"];
        [serviceDictionary setObject:photoURL forKey:@"photoURL"];
        [serviceDictionary setObject:[LocalTwitterUser localTwitterUser] forKey:@"localUser"];
        
        iOSSService *twitter = [[iOSSService alloc] initWithDictionary:serviceDictionary];
        [services addObject:twitter];
        
        
        [serviceDictionary removeAllObjects];
        [serviceDictionary setObject:@"Foursquare" forKey:@"name"];
        photoURL = [[NSBundle mainBundle] URLForResource:@"foursquare_trans" withExtension:@"png"];
        [serviceDictionary setObject:photoURL forKey:@"photoURL"];
        [serviceDictionary setObject:[LocalFoursquareUser localFoursquareUser] forKey:@"localUser"];
        
        iOSSService *foursquare = [[iOSSService alloc] initWithDictionary:serviceDictionary];
        [services addObject:foursquare];
        
        iOSServicesDataSource *servicesDataSource = [[iOSServicesDataSource alloc] initWithSources:services];
        servicesDataSource.displayDoneButton = YES;
        self.dataSource = servicesDataSource;
        self.variableHeightRows = YES;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        NSMutableArray *services = [NSMutableArray array];
        
        NSMutableDictionary *serviceDictionary = [NSMutableDictionary dictionary];
        [serviceDictionary setObject:@"Instagram" forKey:@"name"];
        NSURL *photoURL = [[NSBundle mainBundle] URLForResource:@"instagram_trans" withExtension:@"png"];
        [serviceDictionary setObject:photoURL forKey:@"photoURL"];
        [serviceDictionary setObject:[LocalInstagramUser localInstagramUser] forKey:@"localUser"];
        
        iOSSService *instagram = [[iOSSService alloc] initWithDictionary:serviceDictionary];
        [services addObject:instagram];
        
        
        [serviceDictionary removeAllObjects];
        [serviceDictionary setObject:@"Twitter" forKey:@"name"];
        photoURL = [[NSBundle mainBundle] URLForResource:@"twitter-logo" withExtension:@"png"];
        [serviceDictionary setObject:photoURL forKey:@"photoURL"];
        [serviceDictionary setObject:[LocalTwitterUser localTwitterUser] forKey:@"localUser"];
        
        iOSSService *twitter = [[iOSSService alloc] initWithDictionary:serviceDictionary];
        [services addObject:twitter];
        
        
        [serviceDictionary removeAllObjects];
        [serviceDictionary setObject:@"Foursquare" forKey:@"name"];
        photoURL = [[NSBundle mainBundle] URLForResource:@"foursquare_trans" withExtension:@"png"];
        [serviceDictionary setObject:photoURL forKey:@"photoURL"];
        [serviceDictionary setObject:[LocalFoursquareUser localFoursquareUser] forKey:@"localUser"];
        
        iOSSService *foursquare = [[iOSSService alloc] initWithDictionary:serviceDictionary];
        [services addObject:foursquare];
        
        iOSServicesDataSource *servicesDataSource = [[iOSServicesDataSource alloc] initWithSources:services];
        self.dataSource = servicesDataSource;
        self.variableHeightRows = YES;
    }
    return self;
}

- (id)initWithDataSource:(iOSServicesDataSource*)servicesDataSource
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.dataSource = servicesDataSource;
        self.variableHeightRows = YES;
    }
    
    return self;
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (void)addService:(iOSSService*)service
{
    //notify delegate
    if ([self.serviceControllerDelegate respondsToSelector:@selector(servicesViewController:didSelectService:)]) {
        [self.serviceControllerDelegate servicesViewController:self 
                                              didSelectService:service];
    }
}

#pragma mark - Table view delegate

- (id<UITableViewDelegate>)createDelegate
{
    return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
            case 0:
        {
            if ([self.serviceControllerDelegate respondsToSelector:@selector(servicesViewController:didSelectService:)]) {
                iOSSService *service = [self.dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
                
                //cwnote: this probably needs to take a completion handler.
                [self.serviceControllerDelegate servicesViewController:self 
                                                      didSelectService:service];
                [tableView reloadData];
            }
        }
            break;
        case 1:
        {
            //tell delegate done button was pressed!
            if ([self.serviceControllerDelegate respondsToSelector:@selector(servicesViewControllerDidSelectDoneButton:)]) {
                [self.serviceControllerDelegate servicesViewControllerDidSelectDoneButton:self];
            }
        }
            break;
        default:
            break;
    }
    
    /*
    id<iOSSocialLocalUserProtocol> localUser = service.localUser;
    
    if ([service isConnected]) {
        //[self addService:service];
        
        //[localUser logout];
        //[tableView reloadData];
    } else {
        [localUser authenticateFromViewController:self 
                            withCompletionHandler:^(NSError *error){
                       if (!error) {
                           [self addService:service];
                           [tableView reloadData];
                       }}];
    }
    */
    //cwnote: done button if no navigation controller?
    /*
    switch (indexPath.section) {
        case iOSSServicesTableSectionDoneButton:
        {
            //cell = [PRPBasicSettingsCell cellForTableView:tableView]; 
            switch (indexPath.row) {
                case iOSSServicesSecDoneRowDoneButton: 
                    [self dismissModalViewControllerAnimated:YES];
                    break;
                default:
                    NSAssert1(NO, @"Unexpected row in Favorites section: %d", indexPath.row);
                    break; 
            }
        }
            break;
        default:
            break;
    }
    */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cwnote: need to make this dynamic some how
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
        return 100.0f;
    }
    
    return 75.0f;
}

- (void)refreshUI
{
    [self.tableView reloadData];
}

@end
