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

static iOSServicesDataSource *servicesDataSource = nil;

@interface iOSServicesDataSource ()

@property(nonatomic, readwrite, assign) NSInteger count;
@property(nonatomic, retain)            NSMutableArray *psDelegates;
@property(nonatomic, copy)            NSArray *items;

@end

@implementation iOSServicesDataSource

@synthesize title;
@synthesize count;
@synthesize psDelegates;
@synthesize model;
@synthesize items;
@synthesize message;
@synthesize displayDoneButton;

+ (iOSServicesDataSource *)servicesDataStore
{
    @synchronized(self) {
        if(servicesDataSource == nil)
            servicesDataSource = [[super allocWithZone:NULL] init];
    }
    return servicesDataSource;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithSources:(NSArray*)sources
{
    self = [self init];
    if (self) {
        
        self.items = sources;
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

/*
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.displayDoneButton) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowsInSection = [self numberOfObjects];

    if (self.displayDoneButton) {
        //return for each section
        switch (section) {
            case 0:
                break;
            case 1:
                rowsInSection = 1;
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
                iOSSService *service = [self.items objectAtIndex:[indexPath row]];
                
                iOSSServiceTableViewCell *cell = [iOSSServiceTableViewCell cellForTableView:tableView];
                cell.service = service;
                
                theCell = cell;
            }
                break;
            case 1:
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
        iOSSService *service = [self.items objectAtIndex:[indexPath row]];
        
        iOSSServiceTableViewCell *cell = [iOSSServiceTableViewCell cellForTableView:tableView];
        cell.service = service;
        
        theCell = cell;
    }
    
    return theCell;
}

+ (NSArray*)lettersForSectionsWithSearch:(BOOL)search summary:(BOOL)summary
{
    return nil;
}

- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath
{
    iOSSService *service = [self.items objectAtIndex:[indexPath row]];
    return service;
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
