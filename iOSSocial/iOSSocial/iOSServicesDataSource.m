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
#import "LocalInstagramUser.h"
#import "LocalTwitterUser.h"
#import "LocalFoursquareUser.h"

@interface iOSServicesDataSource ()

@property(nonatomic, readwrite, assign) NSInteger count;
@property(nonatomic, retain)            NSMutableArray *psDelegates;
@property(nonatomic, retain)            NSArray *items;

@end

@implementation iOSServicesDataSource

@synthesize title;
@synthesize count;
@synthesize psDelegates;
@synthesize model;
@synthesize items;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
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
        
        self.items = services;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfObjects];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    iOSSService *service = [self.items objectAtIndex:[indexPath row]];
    
    iOSSServiceTableViewCell *cell = [iOSSServiceTableViewCell cellForTableView:tableView];
    cell.service = service;
    return cell;
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

/*
 - (void)modelDidStartLoad:(id<TTModel>)model;
 
 - (void)modelDidFinishLoad:(id<TTModel>)model;
 
 - (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error;
 
 - (void)modelDidCancelLoad:(id<TTModel>)model;
 */

/**
 * Informs the delegate that the model has changed in some fundamental way.
 *
 * The change is not described specifically, so the delegate must assume that the entire
 * contents of the model may have changed, and react almost as if it was given a new model.
 */
/*
 - (void)modelDidChange:(id<TTModel>)model;
 
 - (void)model:(id<TTModel>)model didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
 
 - (void)model:(id<TTModel>)model didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
 
 - (void)model:(id<TTModel>)model didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
 */

/**
 * Informs the delegate that the model is about to begin a multi-stage update.
 *
 * Models should use this method to condense multiple updates into a single visible update.
 * This avoids having the view update multiple times for each change.  Instead, the user will
 * only see the end result of all of your changes when you call modelDidEndUpdates.
 */
//- (void)modelDidBeginUpdates:(id<TTModel>)model;

/**
 * Informs the delegate that the model has completed a multi-stage update.
 *
 * The exact nature of the change is not specified, so the receiver should investigate the
 * new state of the model by examining its properties.
 */
//- (void)modelDidEndUpdates:(id<TTModel>)model;

@end
