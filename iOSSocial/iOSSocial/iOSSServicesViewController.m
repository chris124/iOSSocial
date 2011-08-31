//
//  iOSSServicesViewController.m
//  InstaBeta
//
//  Created by Christopher White on 7/21/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "iOSSServicesViewController.h"
#import "iOSServicesDataSource.h"
#import "iOSSocialServicesStore.h"
#import "iOSSocialLocalUser.h"

@interface iOSSServicesViewController ()

@property(nonatomic, copy)  ServicesViewControllerHandler servicesViewControllerHandler;

@end

@implementation iOSSServicesViewController

@synthesize serviceControllerDelegate=_serviceControllerDelegate;
@synthesize servicesViewControllerHandler;

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        iOSServicesDataSource *servicesDataSource = [[iOSServicesDataSource alloc] initWithSources:nil];
        servicesDataSource.displayDoneButton = YES;
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
            id<iOSSocialLocalUserProtocol> localUser = [self.dataSource tableView:tableView objectForRowAtIndexPath:indexPath];

            if ([localUser isAuthenticated]) {
                [localUser logout];
                [self refreshUI];
            } else {
                [localUser authenticateFromViewController:self 
                                    withCompletionHandler:^(NSError *error){
                                        if (!error) {
                                            [self refreshUI];
                                        }
                                    }];
            }

            /*
            if ([self.serviceControllerDelegate respondsToSelector:@selector(servicesViewController:didSelectService:)]) {
                iOSSService *service = [self.dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
                
                //cwnote: this probably needs to take a completion handler.
                [self.serviceControllerDelegate servicesViewController:self 
                                                      didSelectService:service];
                [tableView reloadData];
            }
            */
        }
            break;
        case 1:
        {
            //cwnote: get back a service object here. need to then get a local user object for the service and authorize that bad boy? 
            //local user object factory that takes a service object? hmmm
            
            id<iOSSocialServiceProtocol> service = [self.dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
            
            id<iOSSocialLocalUserProtocol> localUser = [service localUser];
            
            [localUser authenticateFromViewController:self 
                                withCompletionHandler:^(NSError *error){
                                    if (!error) {
                                        [self refreshUI];
                                    }
                                }];
        }
            break;
        case 2:
        {
            //tell delegate done button was pressed!
            
            if (self.servicesViewControllerHandler) {
                self.servicesViewControllerHandler();
                self.servicesViewControllerHandler = nil; 
            }
            
            /*
            if ([self.serviceControllerDelegate respondsToSelector:@selector(servicesViewControllerDidSelectDoneButton:)]) {
                [self.serviceControllerDelegate servicesViewControllerDidSelectDoneButton:self];
            }
            */
        }
            break;
        default:
            break;
    }
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

- (void)presentModallyFromViewController:(UIViewController*)vc 
                   withCompletionHandler:(ServicesViewControllerHandler)completionHandler
{
    self.servicesViewControllerHandler = completionHandler;
    
    [vc presentModalViewController:self animated:YES];
}

@end
