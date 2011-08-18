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

/*
enum iOSSServicesTableSections { 
    iOSSServicesTableSectionServices = 0, 
    iOSSServicesTableSectionDoneButton,
    iOSSServicesTableNumSections,
};

enum iOSSServicesRows { 
    iOSSServicesSecServicesRowInstagram = 0, 
    iOSSServicesSecServicesRowTwitter, 
    iOSSServicesSecServicesRowFoursquare, 
    iOSSServicesSecServicesNumRows,
};

enum iOSSDoneRows {
    iOSSServicesSecDoneRowDoneButton = 0,
    iOSSServicesSecDoneNumRows,
};
*/

@implementation iOSSServicesViewController

@synthesize serviceControllerDelegate=_serviceControllerDelegate;

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        iOSServicesDataSource *servicesDataSource = [[iOSServicesDataSource alloc] init];
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
        iOSServicesDataSource *servicesDataSource = [[iOSServicesDataSource alloc] init];
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
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //cwnote: what if no nav controller? showing modally and need to add done button?
 
    // Return the number of sections.
    return iOSSServicesTableNumSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //cwnote: what if no nav controller? showing modally and need to add done button?
 
    switch (section) {
        case iOSSServicesTableSectionServices:
            return iOSSServicesSecServicesNumRows; 
        case iOSSServicesTableSectionDoneButton:
            return iOSSServicesSecDoneNumRows; 
        default:
            iOSSLog(@"Unexpected section (%d)", section); break;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //cwnote: what if no nav controller? showing modally and need to add done button?
 
    switch (section) {
        case iOSSServicesTableSectionServices:
            return @"Services"; 
        case iOSSServicesTableSectionDoneButton:
            return @"Done"; 
        default:
            iOSSLog(@"Unexpected section (%d)", section); break;
    }
    
    return nil;
}
*/
/*
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    //cwnote: what if no nav controller? showing modally and need to add done button?
 
    switch (section) {
        case iOSSServicesTableSectionServices:
            return @"Bada"; 
        case iOSSServicesTableSectionDoneButton:
            return @"Bip"; 
        default:
            iOSSLog(@"Unexpected section (%d)", section); break;
    }
    
    return nil;
}
*/
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    switch (indexPath.section) {
        case iOSSServicesTableSectionDoneButton:
        {
            //cell = [PRPBasicSettingsCell cellForTableView:tableView]; 
            switch (indexPath.row) {
                case iOSSServicesSecDoneRowDoneButton: 
                    cell.textLabel.text = @"Done"; 
                    //cell.detailTextLabel.text = @"Mets"; 
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
    
    return cell;
}
*/

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
    iOSSService *service = [self.dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
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

@end
