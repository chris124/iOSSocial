//
//  iOSServicesDataSource.m
//  PhotoStream
//
//  Created by Christopher White on 8/4/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "iOSServicesDataSource.h"
#import "iOSSLog.h"
#import "iOSSServiceTableViewCell.h"
#import "iOSSocialServicesStore.h"
#import "iOSSocialAccountTableViewCell.h"


@interface iOSServicesDataSource ()

@property(nonatomic, retain)            NSMutableArray *services;

@end

@implementation iOSServicesDataSource

@synthesize message;
@synthesize displayDoneButton;
@synthesize services;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithServicesFilter:(NSArray*)filter
{
    self = [self init];
    if (self) {

        self.services = [NSMutableArray arrayWithArray:filter];
    }
    
    return self;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"YOUR ACCOUNTS";
        case 1:
            return @"ADD AN ACCOUNT";
        default:
            iOSSLog(@"Unexpected section (%d)", section); break;
    }
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.displayDoneButton) {
        return 3;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowsInSection = 0;

    if (self.displayDoneButton) {
        //return for each section
        switch (section) {
            case 0:
                rowsInSection = [[iOSSocialServicesStore sharedServiceStore].accounts count];
                break;
            case 1:
                rowsInSection = [self.services count];
                break;
            case 2:
                rowsInSection = 1;
                break;
            default:
                break;
        }
    } else {
        //return for each section
        switch (section) {
            case 0:
                rowsInSection = [[iOSSocialServicesStore sharedServiceStore].accounts count];
                break;
            case 1:
                rowsInSection = [self.services count];
                break;
            default:
                break;
        }
    }
    return rowsInSection;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *theCell = nil;
    
    if (self.displayDoneButton) {
        switch (indexPath.section) {
            case 0:
            {
                id<iOSSocialLocalUserProtocol> localUser = [[iOSSocialServicesStore sharedServiceStore].accounts objectAtIndex:[indexPath row]];
                 
                iOSSocialAccountTableViewCell *cell = [iOSSocialAccountTableViewCell cellForTableView:tableView];
                cell.localUser = localUser;
                 
                theCell = cell;
            }
                break;
            case 1:
            {
                id<iOSSocialServiceProtocol> service = [self.services objectAtIndex:[indexPath row]];
                
                iOSSServiceTableViewCell *cell = [iOSSServiceTableViewCell cellForTableView:tableView];
                cell.service = service;
                
                theCell = cell;
            }
                break;
            case 2:
            {
                static NSString *CellIdentifier = @"Cell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                cell.textLabel.text = @"Done";

                theCell = cell;
            }
                break;
            default:
                break;
        }
    } else {
        switch (indexPath.section) {
            case 0:
            {
                id<iOSSocialLocalUserProtocol> localUser = [[iOSSocialServicesStore sharedServiceStore].accounts objectAtIndex:[indexPath row]];
                
                iOSSocialAccountTableViewCell *cell = [iOSSocialAccountTableViewCell cellForTableView:tableView];
                cell.localUser = localUser;
                
                theCell = cell;
            }
                break;
            case 1:
            {
                id<iOSSocialServiceProtocol> service = [self.services objectAtIndex:[indexPath row]];
                
                iOSSServiceTableViewCell *cell = [iOSSServiceTableViewCell cellForTableView:tableView];
                cell.service = service;
                
                theCell = cell;
            }
                break;
            default:
                break;
        }
    }
    
    return theCell;
}

@end
