//
//  FacebookPhotoAlbum.m
//  MadRaces
//
//  Created by Christopher White on 7/7/11.
//  Copyright 2011 Betaworks. All rights reserved.
//

#import "FacebookPhotoAlbum.h"
#import "SocialManager.h"
#import "FBConnect.h"
#import "FacebookPhoto.h"
#import "Three20Network/TTModelDelegate.h"

typedef enum _FBPhotoAlbumLoadState {
	FBPhotoAlbumLoadStateIdle = 0,
    FBPhotoAlbumLoadStateLoading = 1,
    FBPhotoAlbumLoadStateLoaded
} FBPhotoAlbumLoadState;

@interface FacebookPhotoAlbum () <FBRequestDelegate>

@property(nonatomic, readwrite, retain) NSString *albumID;
@property(nonatomic, readwrite, retain) NSString *name;
@property(nonatomic, readwrite, retain) NSString *description;
@property(nonatomic, readwrite, assign) NSInteger count;
@property(nonatomic, retain)            NSMutableArray *psDelegates;
@property(nonatomic, retain)            NSMutableArray *photos;
@property(nonatomic, assign)            FBPhotoAlbumLoadState loadState;

@end

@implementation FacebookPhotoAlbum

@synthesize albumID;
@synthesize name;
@synthesize description;
@synthesize count;
@synthesize title;
@synthesize psDelegates;
@synthesize photos;
@synthesize loadState;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary*)albumDictionary
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.albumID = [albumDictionary objectForKey:@"id"];
        self.name = [albumDictionary objectForKey:@"name"];
        self.description = [albumDictionary objectForKey:@"description"];
        self.count = [(NSNumber*)[albumDictionary objectForKey:@"count"] intValue];
        self.loadState = FBPhotoAlbumLoadStateIdle;
    }
    
    return self;
}

- (void)loadPhotos
{
    //download the photos for the album and save them to an array

    //say that we are loading
    self.loadState = FBPhotoAlbumLoadStateLoading;
    
    NSString *path = [NSString stringWithFormat:@"%@/photos", self.albumID];
    [[SocialManager socialManager].facebook requestWithGraphPath:path andDelegate:self];
}

#pragma mark -
#pragma mark FBRequestDelegate

- (void)requestLoading:(FBRequest *)request
{
    NSLog(@"requestLoading");
    
    for (id<TTModelDelegate> delegate in self.psDelegates) {
        [delegate modelDidStartLoad:self];
    }
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"didReceiveResponse");
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError");
    
    for (id<TTModelDelegate> delegate in self.psDelegates) {
        [delegate model:self didFailLoadWithError:error];
    }
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    NSLog(@"didLoad");
    
    NSDictionary *photosDictionary = [(NSDictionary*)result objectForKey:@"data"];
    
    self.photos = [NSMutableArray array];
    NSInteger index = 0;
    for (NSDictionary *photoDictionary in photosDictionary) {
        //create a photo object for each
        FacebookPhoto *photo = [[[FacebookPhoto alloc] initWithDictionary:photoDictionary] autorelease];
        photo.index = index;
        photo.photoSource = self;
        [self.photos addObject:photo];
        index++;
    } 
    
    //say that we are done loading
    self.loadState = FBPhotoAlbumLoadStateLoaded;
    
    for (id<TTModelDelegate> delegate in self.psDelegates) {
        [delegate modelDidFinishLoad:self];
    }
}

- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data
{
    NSLog(@"didLoadRawResponse");
}

- (NSString*)title
{
    return self.name;
}

- (id<TTPhoto>)photoAtIndex:(NSInteger)index
{
    if (index <= self.maxPhotoIndex) {
        return [self.photos objectAtIndex:index];
    }
    return nil;
}

- (NSInteger)numberOfPhotos
{
    NSLog(@"photo count: %d", [self.photos count]);
    return [self.photos count];
}

- (NSInteger)maxPhotoIndex
{
    NSLog(@"max photo index: %d", [self.photos count]-1);
    return [self.photos count]-1;
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
    NSLog(@"load");
    
    [self loadPhotos];
}

/**
 * Cancels a load that is in progress.
 *
 * Default implementation does nothing.
 */
- (void)cancel
{
    NSLog(@"cancel");
}

/**
 * Invalidates data stored in the cache or optionally erases it.
 *
 * Default implementation does nothing.
 */
- (void)invalidate:(BOOL)erase
{
    NSLog(@"invalidate");
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

+ (NSArray*)lettersForSectionsWithSearch:(BOOL)search summary:(BOOL)summary
{
    return nil;
}

- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath
{
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
    NSLog(@"bah");
}

/**
 * Informs the data source that its model loaded.
 *
 * That would be a good time to prepare the freshly loaded data for use in the table view.
 */
- (void)tableViewDidLoadModel:(UITableView*)tableView
{
    
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
    NSLog(@"bah");
}

- (void)dealloc
{
    [photos release];
    [title release];
    [psDelegates release];
    [description release];
    [name release];
    [albumID release];
    [super dealloc];
}

@end

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


/*
{
    comments =     {
        data =         (
                        {
                            "created_time" = "2011-03-16T04:05:38+0000";
                            from =                 {
                                id = 9508713;
                                name = "Chris Kuruc";
                            };
                            id = "10150106153231510_14946310";
                            message = "how long you down there?  i arrive on the 24th.";
                        },
                        {
                            "created_time" = "2011-03-16T04:24:36+0000";
                            from =                 {
                                id = 623441509;
                                name = "Christopher White";
                            };
                            id = "10150106153231510_14946541";
                            message = "Just got back yesterday.";
                        },
                        {
                            "created_time" = "2011-03-17T06:03:56+0000";
                            from =                 {
                                id = 1259040724;
                                name = "Sandy Griffith";
                            };
                            id = "10150106153231510_14965719";
                            message = "I'm going on Sunday for a conference.  Sorry I'ml missing you but I'd love some recommendations!";
                        },
                        {
                            "created_time" = "2011-03-17T12:54:44+0000";
                            from =                 {
                                id = 623441509;
                                name = "Christopher White";
                            };
                            id = "10150106153231510_14968988";
                            message = "Hit up the mexican dive place on 14th between collins and washington! There's also a great French Cafe on Espanola with awesome crepes, coffee, etc. Big Pink has good brunch/breakfast. :) What up Sandy?";
                        },
                        {
                            "created_time" = "2011-03-21T03:46:25+0000";
                            from =                 {
                                id = 726540350;
                                name = "Leanna Yip";
                            };
                            id = "10150106153231510_15031726";
                            message = "nice photos of you & your food guys!!!";
                        },
                        {
                            "created_time" = "2011-03-21T03:53:41+0000";
                            from =                 {
                                id = 623441509;
                                name = "Christopher White";
                            };
                            id = "10150106153231510_15031800";
                            message = "Roll with us next year and you can be part of our WMC food crew too. :D Hit me up if you roll through NYC!";
                        },
                        {
                            "created_time" = "2011-03-21T15:07:53+0000";
                            from =                 {
                                id = 613727109;
                                name = "Richard Ting";
                            };
                            id = "10150106153231510_15038075";
                            message = "good to see that you guys are still partying.";
                        },
                        {
                            "created_time" = "2011-03-22T17:20:54+0000";
                            from =                 {
                                id = 623441509;
                                name = "Christopher White";
                            };
                            id = "10150106153231510_15058421";
                            message = "yo rich! none of our friends have been brave enough to tell us to grow up already. :D";
                        }
                        );
    };
    count = 34;
    "cover_photo" = 6924051;
    "created_time" = "2011-03-16T03:52:02+0000";
    description = "chillin in south beach, miami, with adam, gavin, and lauren. GOOD times!! sleep on beach! ha!";
    from =     {
        id = 623441509;
        name = "Christopher White";
    };
    id = 10150106153231510;
    link = "http://graph.facebook.com/album.php?fbid=10150106153231510&id=623441509&aid=282209";
    location = "Miami Beach, FL";
    name = "3-2011 - WMC";
    privacy = custom;
    type = normal;
    "updated_time" = "2011-03-21T03:22:05+0000";
}
*/
