//
//  LocalFacebookUser.m
//  MadRaces
//
//  Created by Christopher White on 7/5/11.
//  Copyright 2011 Betaworks. All rights reserved.
//

#import "LocalFacebookUser.h"
#import "KeychainItemWrapper.h"
#import "SocialManager.h"
#import "FBConnect.h"
#import "FacebookPhotoAlbum.h"

@interface FacebookUser () <FBRequestDelegate>

typedef enum _FBRequestType {
	FBUserRequestType = 0,
    FBUserPictureRequestType = 1,
    FBUserFriendsRequestType = 2,
    FBUsersRequestType = 3, 
    FBCreatePhotoAlbumRequestType = 4,
    FBUserPhotoAlbumsRequestType
} FBRequestType;

- (void)recordRequest:(FBRequest*)request withType:(FBRequestType)type;
- (FBRequestType)requestTypeForRequest:(FBRequest*)request;

@end

@interface LocalFacebookUser () <FBRequestDelegate, FBSessionDelegate> 

@property(nonatomic, readwrite, retain) NSArray *friends;
@property(nonatomic, copy)              AuthenticationHandler authenticationHandler;
@property(nonatomic, copy)              FindFriendsHandler findFriendsHandler;
@property(nonatomic, copy)              LoadUsersHandler loadUsersHandler;
@property(nonatomic, copy)              CreatePhotoAlbumHandler createPhotoAlbumHandler;
@property(nonatomic, copy)              LoadPhotoAlbumsHandler loadPhotoAlbumsHandler;
@property(nonatomic, retain)            KeychainItemWrapper *accessTokenItem;

@end


static LocalFacebookUser *localFacebookUser = nil;

NSMutableArray *users = nil;
NSInteger usersCount = 0;

@implementation LocalFacebookUser

@synthesize authenticated;
@synthesize friends;
@synthesize authenticationHandler;
@synthesize findFriendsHandler;
@synthesize accessTokenItem;
@synthesize loadUsersHandler;
@synthesize createPhotoAlbumHandler;
@synthesize loadPhotoAlbumsHandler;

+ (LocalFacebookUser *)localFacebookUser
{
    @synchronized(self) {
        if(localFacebookUser == nil)
            localFacebookUser = [[super allocWithZone:NULL] init];
    }
    return localFacebookUser;
}

+ (id)allocWithZone:(NSZone *)zone 
{
    return [[self localFacebookUser] retain];
}

- (id)copyWithZone:(NSZone *)zone 
{
    return self;
}

- (id)retain 
{
    return self;
}

- (unsigned)retainCount 
{
    return UINT_MAX; //denotes an object that cannot be released
}
/*
- (void)release 
{
    // never release
}
*/
- (id)autorelease 
{
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"AccessToken" accessGroup:nil];
        self.accessTokenItem = wrapper;
        [wrapper release];
        
        //fetch access token and expiration date from keychain and assign to facebook object
        NSArray *components = [[self.accessTokenItem objectForKey:@"v_Data"] componentsSeparatedByString:@"&"];
        
        if (1 < [components count]) {
            NSString *accessToken = [components objectAtIndex:0];
            
            NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
            [dateFormat setDateStyle:kCFDateFormatterFullStyle];
            NSDate *expirationDate = [dateFormat dateFromString:[components objectAtIndex:1]];
            
            if (accessToken) {
                [SocialManager socialManager].facebook.accessToken = accessToken;
                [SocialManager socialManager].facebook.expirationDate = expirationDate;
            }
        }
    }
    
    return self;
}

- (void)dealloc
{
    [friends release];
    [accessTokenItem release];
    [authenticationHandler release];
    [findFriendsHandler release];
    [loadUsersHandler release];
    [createPhotoAlbumHandler release];
    [loadPhotoAlbumsHandler release];
    [super dealloc];
}

- (BOOL)isAuthenticated 
{
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* facebookCookies = [cookies cookiesForURL:[NSURL URLWithString:@"http://login.facebook.com"]];
    
    BOOL hasCookies = NO;
    if (0 < [facebookCookies count]) {
        hasCookies = YES;
    }
    
    if (NO == [[SocialManager socialManager].facebook isSessionValid] && !hasCookies)
        return NO;
    return YES;
}

- (void)fetchLocalUserData
{
    //since they're logged in, fetch their details
    FBRequest *request = [[SocialManager socialManager].facebook requestWithGraphPath:@"me" 
                                                 andDelegate:self];
    [self recordRequest:request withType:FBUserRequestType];
}

- (void)authenticateUserPermissions:(NSArray*)permissions 
              withCompletionHandler:(AuthenticationHandler)completionHandler
{
    self.authenticationHandler = completionHandler;
    
    //cwnote: also see if permissions have changed!!!
    if (NO == [self isAuthenticated]) {

        [[SocialManager socialManager].facebook authorize:permissions 
                                                 delegate:self];
    } else {
        if (self.authenticationHandler) {
            self.authenticationHandler(nil);
            self.authenticationHandler = nil;
        }
        [self fetchLocalUserData];
    }
}

- (void)loadFriendsWithCompletionHandler:(FindFriendsHandler)completionHandler
{
    self.findFriendsHandler = completionHandler;

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"friends.getAppUsers" forKey:@"method"];
    
    //use the old REST api to get friends who use this app
    FBRequest *request = [[SocialManager socialManager].facebook requestWithParams:params andDelegate:self];
    
    [self recordRequest:request withType:FBUserFriendsRequestType];
}

- (void)loadUsersForIdentifiers:(NSArray *)identifiers withCompletionHandler:(LoadUsersHandler)completionHandler
{
    self.loadUsersHandler = completionHandler;
    
    //need to save all of the results in an array. ugh. as we get each one, mark that we've updated it. create a FacebookUser object for each one

    if (!users) {
        users = [[NSMutableArray alloc] init];
    } else {
        [users removeAllObjects];
    }
    
    usersCount = [identifiers count];
    
    for (NSNumber *identifier in identifiers) {
        NSString *path = [identifier stringValue];
        FBRequest *request = [[SocialManager socialManager].facebook requestWithGraphPath:path andDelegate:self];
        [self recordRequest:request withType:FBUsersRequestType];
    }
}

- (void)createPhotoAlbumWithName:(NSString*)name 
                         message:(NSString*)message 
                          photos:(NSArray*)photos 
           withCompletionHandler:(CreatePhotoAlbumHandler)completionHandler
{
    self.createPhotoAlbumHandler = completionHandler;
    
    //cwnote: need to save the photos somehow so that when the album posts we can then post the photos
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:name forKey:@"name"];
    [dictionary setObject:message forKey:@"message"];
    FBRequest *request = [[SocialManager socialManager].facebook requestWithGraphPath:@"me/albums" 
                                                                            andParams:dictionary 
                                                                        andHttpMethod:@"POST"
                                                                          andDelegate:self];
    [self recordRequest:request withType:FBCreatePhotoAlbumRequestType];
}

- (void)loadPhotoAlbumsWithCompletionHandler:(LoadPhotoAlbumsHandler)completionHandler
{
    self.loadPhotoAlbumsHandler = completionHandler;
    
    FBRequest *request = [[SocialManager socialManager].facebook requestWithGraphPath:@"me/albums" 
                                                                          andDelegate:self];
    [self recordRequest:request withType:FBUserPhotoAlbumsRequestType];
}

#pragma mark -
#pragma mark FBSessionDelegate

- (void)fbDidLogin
{
    //save the access token and expiration date in the keychain for retrieval later when app starts. will be used to initialize facebook 

    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormat setDateStyle:kCFDateFormatterFullStyle];
    NSString *date = [dateFormat stringFromDate:[SocialManager socialManager].facebook.expirationDate];
    
    NSString *accessToken = [NSString stringWithFormat:@"%@&%@", [SocialManager socialManager].facebook.accessToken, date];
    [self.accessTokenItem setObject:accessToken forKey:@"v_Data"];
    
    NSLog(@"fbDigLogin");
    
    if (self.authenticationHandler) {
        self.authenticationHandler(nil);
        self.authenticationHandler = nil;
    }
    
    [self fetchLocalUserData];
    
    //issue notification? UserAuthenticationDidChangeNotificationName
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    NSLog(@"fbDidNotLogin");

    if (self.authenticationHandler) {
        self.authenticationHandler(nil);
        self.authenticationHandler = nil;
    }
}

- (void)fbDidLogout
{
    [self.accessTokenItem resetKeychainItem];
    
    NSLog(@"fbDidLogout");
}

#pragma mark -
#pragma mark FBRequestDelegate

- (void)requestLoading:(FBRequest *)request
{
    [super requestLoading:request];
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    [super request:request didReceiveResponse:response];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    FBRequestType requestType = [self requestTypeForRequest:request];
    switch (requestType) {
            
        case FBUserFriendsRequestType:
        {
             if (self.findFriendsHandler) {
                 self.findFriendsHandler(nil, nil);
                 self.findFriendsHandler = nil;
             }
        }
            break;
            
        case FBUsersRequestType:
        {
            FacebookUser *user = [[[FacebookUser alloc] init] autorelease];
            
            //save this user
            [users addObject:user];
            
            if (usersCount == [users count]) {
                if (self.loadUsersHandler) {
                    self.loadUsersHandler(users, nil);
                    [users removeAllObjects];
                    self.loadUsersHandler = nil;
                }
            }
        }
            break;
            
        case FBCreatePhotoAlbumRequestType:
        {
            //call completion handler with error
            if (self.createPhotoAlbumHandler) {
                self.createPhotoAlbumHandler(nil);
                self.createPhotoAlbumHandler = nil;
            }
        }
            break;
            
        case FBUserPhotoAlbumsRequestType:
        {
            //call completion handler with error
            if (self.loadPhotoAlbumsHandler) {
                self.loadPhotoAlbumsHandler(nil, nil);
                self.loadPhotoAlbumsHandler = nil;
            }
        }
            break;
            
        default:
            break;
    }
    
    [super request:request didFailWithError:error];
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    FBRequestType requestType = [self requestTypeForRequest:request];
    switch (requestType) {
            
        case FBUserFriendsRequestType:
        {
             //an array of ids of facebook friends
             self.friends = (NSArray*)result;

             //create users and return them
             if (self.findFriendsHandler) {
                 self.findFriendsHandler(self.friends, nil);
                 self.findFriendsHandler = nil;
             }
        }
            break;
        
        case FBUsersRequestType:
        {
            NSDictionary *dictionary = (NSDictionary*)result;
            FacebookUser *user = [[[FacebookUser alloc] initWithDictionary:dictionary] autorelease];
            
            //save this user
            [users addObject:user];
            
            if (usersCount == [users count]) {
                if (self.loadUsersHandler) {
                    self.loadUsersHandler(users, nil);
                    [users removeAllObjects];
                    self.loadUsersHandler = nil;
                }
            }
        }
            break;
            
        case FBCreatePhotoAlbumRequestType:
        {
            //if there are no photos to post to the album, we are done. otherwise, post them to the album. need the album id
            //NSDictionary *dictionary = (NSDictionary*)result;
            //NSString *albumID = [dictionary objectForKey:@"id"];
            
            //issue the posting of the photos...somehow link the request to the photo album request. ugh.
            if (self.createPhotoAlbumHandler) {
                self.createPhotoAlbumHandler(nil);
                self.createPhotoAlbumHandler = nil;
            }
        }
            break;
            
        case FBUserPhotoAlbumsRequestType:
        {
            //cwnote: need permissions for album. 
            
            NSDictionary *albumsDictionary = [(NSDictionary*)result objectForKey:@"data"];
            
            NSMutableArray *albums = [NSMutableArray array];
            for (NSDictionary *albumDictionary in albumsDictionary) {
                //create an album object for each
                FacebookPhotoAlbum *album = [[[FacebookPhotoAlbum alloc] initWithDictionary:albumDictionary] autorelease];
                //save the name and description of the album
                [albums addObject:album];
            }
            
            //call completion handler with error
            if (self.loadPhotoAlbumsHandler) {
                self.loadPhotoAlbumsHandler(albums, nil);
                self.loadPhotoAlbumsHandler = nil;
            }
        }
            
        default:
            break;
    }
    
    [super request:request didLoad:result];
}

- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data
{
    [super request:request didLoadRawResponse:data];
}


@end
