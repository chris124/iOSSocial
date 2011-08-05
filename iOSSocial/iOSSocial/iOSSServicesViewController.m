//
//  iOSSServicesViewController.m
//  InstaBeta
//
//  Created by Christopher White on 7/21/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "iOSSServicesViewController.h"
#import "iOSSocial.h"
#import "LocalInstagramUser.h"
#import "LocalTwitterUser.h"
#import "LocalFoursquareUser.h"
#import "iOSServicesDataSource.h"
#import "iOSSService.h"

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

@implementation iOSSServicesViewController

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
        [localUser logout];
        [tableView reloadData];
    } else {
        [localUser authenticateFromViewController:self 
                            withCompletionHandler:^(NSError *error){
                       if (!error) {
                           NSString *accessToken = [[LocalInstagramUser localInstagramUser] oAuthAccessToken];
                           accessToken = nil;
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
    return 150.0f;
}

@end
support rearranging the table view.
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    switch (indexPath.section) {
        case iOSSServicesTableSectionServices:
        {
            //cell = [PRPBasicSettingsCell cellForTableView:tableView]; 
            switch (indexPath.row) {
                case iOSSServicesSecServicesRowInstagram: 
                {
                    //basic comments relationships likes
                    NSString *scope = @"basic comments relationships likes";
                    [[LocalInstagramUser localInstagramUser] authenticateWithScope:scope  
                                                                fromViewController:self 
                                                             withCompletionHandler:^(NSError *error){
                                                                 if (!error) {
                                                                     NSString *accessToken = [[LocalInstagramUser localInstagramUser] oAuthAccessToken];
                                                                     accessToken = nil;
                                                                 }}];
                }
                    break;
                case iOSSServicesSecServicesRowTwitter: 
                {
                    //NSString *scope = @"basic comments relationships likes";
                    [[LocalTwitterUser localTwitterUser] authenticateWithScope:nil /*scope*/  
                                                            fromViewController:self 
                                                         withCompletionHandler:^(NSError *error){
                                                             if (!error) {
                                                                 NSString *accessToken = [[LocalTwitterUser localTwitterUser] oAuthAccessToken];
                                                             }}];
                }
                    break;
                case iOSSServicesSecServicesRowFoursquare: 
                {
                    NSString *scope = @"";
                    [[LocalFoursquareUser localFoursquareUser] authenticateWithScope:scope 
                                                                  fromViewController:self 
                                                               withCompletionHandler:^(NSError *error){
                                                             if (!error) {
                                                                 NSString *accessToken = [[LocalFoursquareUser localFoursquareUser] oAuthAccessToken];
                                                             }}];
                }
                    break;
                default:
                    NSAssert1(NO, @"Unexpected row in Favorites section: %d", indexPath.row);
                    break; 
            }
        }
            break;
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
}

@end
