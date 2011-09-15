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
//#import "iOSSService.h"
#import "iOSSocialServicesStore.h"
#import "iOSSocialAccountTableViewCell.h"

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

@interface iOSServicesDataSource ()

@property(nonatomic, readwrite, assign) NSInteger count;
@property(nonatomic, retain)            NSMutableArray *psDelegates;
@property(nonatomic, copy)              NSArray *items;
@property(nonatomic, retain)            NSMutableArray *services;

@end

@implementation iOSServicesDataSource

@synthesize title;
@synthesize count;
@synthesize psDelegates;
@synthesize model;
@synthesize items;
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

        if (filter) {
            self.services = [NSMutableArray array];
            
            //filter out the services based on the filter
            for (id<iOSSocialServiceProtocol> service in [iOSSocialServicesStore sharedServiceStore].services) {
                if ([filter containsObject:service.name]) {
                    [self.services addObject:service];
                }
            }
        } else {
            self.services = [iOSSocialServicesStore sharedServiceStore].services;
        }
    }
    
    return self;
}

- (id<TTModel>)model {
    return self;
}

- (NSString*)title
{
    //return self.name;
    return nil;
}

- (id<iOSSServiceProtocol>)objectAtIndex:(NSInteger)index
{
    if (index <= self.maxObjectIndex) {
        return [self.items objectAtIndex:index];
    }
    return nil;
}

- (NSInteger)numberOfObjects
{
    iOSSLog(@"media count: %d", [self.items count]);
    return [self.items count];
}

- (NSInteger)maxObjectIndex
{
    iOSSLog(@"media photo index: %d", [self.items count]-1);
    return [self.items count]-1;
}

/**
 * An array of objects that conform to the TTModelDelegate protocol.
 */
- (NSMutableArray*)delegates
{
    if (nil == self.psDelegates) {
        self.psDelegates = [NSMutableArray array];
    }
    return self.psDelegates;
}

/**
 * Indicates that the data has been loaded.
 *
 * Default implementation returns YES.
 */
- (BOOL)isLoaded
{
    return YES;
}

/**
 * Indicates that the data is in the process of loading.
 *
 * Default implementation returns NO.
 */
- (BOOL)isLoading
{
    return NO;
}

/**
 * Indicates that the data is in the process of loading additional data.
 *
 * Default implementation returns NO.
 */
- (BOOL)isLoadingMore
{
    return NO;
}

/**
 * Indicates that the model is of date and should be reloaded as soon as possible.
 *
 * Default implementation returns NO.
 */
-(BOOL)isOutdated
{
    //need logic to determine if outdated
    return NO;
}

/**
 * Loads the model.
 *
 * Default implementation does nothing.
 */
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
    iOSSLog(@"load");
}

/**
 * Cancels a load that is in progress.
 *
 * Default implementation does nothing.
 */
- (void)cancel
{
    iOSSLog(@"cancel");
}

/**
 * Invalidates data stored in the cache or optionally erases it.
 *
 * Default implementation does nothing.
 */
- (void)invalidate:(BOOL)erase
{
    iOSSLog(@"invalidate");
}

/**
 * Converts the object to a URL using TTURLMap.
 */
- (NSString*)URLValue
{
    return nil;
}

/**
 * Converts the object to a specially-named URL using TTURLMap.
 */
- (NSString*)URLValueWithName:(NSString*)name
{
    return nil;
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

-(IBAction) doneButtonPressed:(id)sender
{
    NSLog(@"doneButtonPressed");
}

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
                
                /*
                UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [doneButton setFrame:cell.frame];
                [doneButton setTitle:@"Done" forState:UIControlStateNormal];
                [cell.contentView addSubview:doneButton];
                [doneButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                */
                
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

+ (NSArray*)lettersForSectionsWithSearch:(BOOL)search summary:(BOOL)summary
{
    return nil;
}

- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            id<iOSSocialLocalUserProtocol> localUser = [[iOSSocialServicesStore sharedServiceStore].accounts objectAtIndex:[indexPath row]];
            
            return localUser;
        }
            break;
        case 1:
        {
            id<iOSSocialServiceProtocol> service = [self.services objectAtIndex:[indexPath row]];
            
            return service;
        }
            break;
        default:
            break;
    }
    
    return nil;
}

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object
{
    return nil;
}

- (NSString*)tableView:(UITableView*)tableView labelForObject:(id)object
{
    return nil;
}

- (NSIndexPath*)tableView:(UITableView*)tableView indexPathForObject:(id)object
{
    return nil;
}

- (void)tableView:(UITableView*)tableView cell:(UITableViewCell*)cell
willAppearAtIndexPath:(NSIndexPath*)indexPath
{
    iOSSLog(@"bah");
}

/**
 * Informs the data source that its model loaded.
 *
 * That would be a good time to prepare the freshly loaded data for use in the table view.
 */
- (void)tableViewDidLoadModel:(UITableView*)tableView
{
    iOSSLog(@"");
}

- (NSString*)titleForLoading:(BOOL)reloading
{
    return @"Loading...";
}

- (UIImage*)imageForEmpty
{
    return nil;
}

- (NSString*)titleForEmpty
{
    return nil;
}

- (NSString*)subtitleForEmpty
{
    return nil;
}

- (UIImage*)imageForError:(NSError*)error
{
    return nil;
}

- (NSString*)titleForError:(NSError*)error
{
    return nil;
}

- (NSString*)subtitleForError:(NSError*)error
{
    return nil;
}


- (NSIndexPath*)tableView:(UITableView*)tableView willUpdateObject:(id)object
              atIndexPath:(NSIndexPath*)indexPath
{
    return nil;
}

- (NSIndexPath*)tableView:(UITableView*)tableView willInsertObject:(id)object
              atIndexPath:(NSIndexPath*)indexPath
{
    return nil;
}

- (NSIndexPath*)tableView:(UITableView*)tableView willRemoveObject:(id)object
              atIndexPath:(NSIndexPath*)indexPath
{
    return nil;
}

- (void)search:(NSString*)text
{
    iOSSLog(@"bah");
}

@end
