//
//  IGUserFollowsDataSource.m
//  PhotoStream
//
//  Created by Christopher White on 8/8/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "IGUserFollowsDataSource.h"
#import "iOSSLog.h"
#import "LocalInstagramUser.h"

typedef enum _FBPhotoAlbumLoadState {
	FBPhotoAlbumLoadStateIdle = 0,
    FBPhotoAlbumLoadStateLoading = 1,
    FBPhotoAlbumLoadStateLoaded
} FBPhotoAlbumLoadState;

@interface IGUserFollowsDataSource ()

@property(nonatomic, readwrite, assign) NSInteger count;
@property(nonatomic, retain)            NSMutableArray *psDelegates;
@property(nonatomic, retain)            NSArray *items;
@property(nonatomic, assign)            FBPhotoAlbumLoadState loadState;

@end

@implementation IGUserFollowsDataSource

@synthesize title;
@synthesize count;
@synthesize psDelegates;
@synthesize model;
@synthesize items;
@synthesize loadState;
@synthesize numberOfObjects;
@synthesize maxObjectIndex;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary*)collectionDictionary
{
    self = [self init];
    if (self) {
        // Initialization code here.
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
/*
- (id<iOSSUserProtocol>)objectAtIndex:(NSInteger)index
{
    if (index <= self.maxObjectIndex) {
        return [self.items objectAtIndex:index];
    }
    return nil;
}
*/
- (NSInteger)numberOfObjects
{
    iOSSLog(@"count: %d", [self.items count]);
    return [self.items count];
}

- (NSInteger)maxObjectIndex
{
    iOSSLog(@"index: %d", [self.items count]-1);
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
    return (FBPhotoAlbumLoadStateLoaded == self.loadState);
}

/**
 * Indicates that the data is in the process of loading.
 *
 * Default implementation returns NO.
 */
- (BOOL)isLoading
{
    return (FBPhotoAlbumLoadStateLoading == self.loadState);
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
    
    self.loadState = FBPhotoAlbumLoadStateLoading;
    
    [[LocalInstagramUser localInstagramUser] fetchFollowsWithCompletionHandler:^(NSArray *users, NSError *error) {
        
        //set the items from the dictionary
        if (error) {
            self.loadState = FBPhotoAlbumLoadStateLoaded;
            
            for (id<TTModelDelegate> delegate in self.psDelegates) {
                [delegate model:self didFailLoadWithError:error];
            }
        } else {
            //
            self.items = users;
            
            for (InstagramUser *user in self.items) {
                user.dataSource = self;
            }
            
            self.loadState = FBPhotoAlbumLoadStateLoaded;
            
            for (id<TTModelDelegate> delegate in self.psDelegates) {
                [delegate modelDidFinishLoad:self];
            }
        }
    }];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfObjects];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cwnote: make a table view cell for this!!!
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    InstagramUser *user = (InstagramUser*)[self.items objectAtIndex:[indexPath row]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", user.alias, user.website];
    cell.imageView.image = nil;
    [user loadPhotoWithCompletionHandler:^(UIImage *photo, NSError *error) {
        cell.imageView.image = photo;
        [cell setNeedsLayout];
    }];
    
    /*
    [user fetchUserDataWithCompletionHandler:^(NSError *error) {
        [cell setNeedsLayout];
    }];
    */
    
    return cell;
}

+ (NSArray*)lettersForSectionsWithSearch:(BOOL)search summary:(BOOL)summary
{
    return nil;
}

- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath
{
    InstagramUser *user = [self.items objectAtIndex:[indexPath row]];
    return user;
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