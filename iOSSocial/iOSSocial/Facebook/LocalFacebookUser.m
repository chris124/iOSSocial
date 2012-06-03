/*
 * Copyright 2011 Mad Races, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "LocalFacebookUser.h"
#import "KeychainItemWrapper.h"
#import "FBConnect.h"
#import "FacebookService.h"
#import "Facebook.h"
#import "FacebookUser+Private.h"
#import "iOSSLog.h"
#import <Security/Security.h>

@interface FacebookUser () <FBRequestDelegate, FBSessionDelegate>

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

@interface LocalFacebookUser () <FBRequestDelegate, FBSessionDelegate, FBDialogDelegate> 

@property(nonatomic, readwrite, retain) NSArray *friends;
@property(nonatomic, copy)              AuthenticationHandler authenticationHandler;
@property(nonatomic, copy)              FindFriendsHandler findFriendsHandler;
@property(nonatomic, copy)              LoadUsersHandler loadUsersHandler;
@property(nonatomic, copy)              CreatePhotoAlbumHandler createPhotoAlbumHandler;
@property(nonatomic, copy)              LoadPhotoAlbumsHandler loadPhotoAlbumsHandler;
@property(nonatomic, retain)            KeychainItemWrapper *accessTokenItem;
@property(nonatomic, retain)            NSString *keychainItemName;
@property(nonatomic, readwrite, retain) NSString *identifier;
@property(nonatomic, copy)              CompletionHandler genericCompletionHandler;

@end

NSString *const iOSSDefaultsKeyFacebookUserDictionary  = @"ioss_facebookUserDictionary";

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
@synthesize servicename;
@synthesize username;
@synthesize identifier;
@synthesize keychainItemName;
@synthesize genericCompletionHandler;

+ (LocalFacebookUser *)localFacebookUser
{
    @synchronized(self) {
        if(localFacebookUser == nil)
            localFacebookUser = [[super allocWithZone:NULL] init];
    }
    return localFacebookUser;
}

+ (void)setLocalFacebookUser:(LocalFacebookUser *)theLocalFacebookUser
{
    localFacebookUser = theLocalFacebookUser;
}

- (NSDictionary *)ioss_facebookUserDictionary 
{ 
    return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-%@", iOSSDefaultsKeyFacebookUserDictionary, self.identifier]];
}

- (void)ioss_setFacebookUserDictionary:(NSDictionary *)theUserDictionary 
{ 
    [[NSUserDefaults standardUserDefaults] setObject:theUserDictionary forKey:[NSString stringWithFormat:@"%@-%@", iOSSDefaultsKeyFacebookUserDictionary, self.identifier]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)init
{
    self = [super init];
    if (self) {

        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef uuidStr = CFUUIDCreateString(kCFAllocatorDefault, uuid);
        self.identifier = (__bridge NSString *)uuidStr;
        CFRelease(uuidStr);
        CFRelease(uuid); 

        self.keychainItemName = [NSString stringWithFormat:@"%@-%@", [[FacebookService sharedService] serviceKeychainItemName], self.identifier];
        
        // Initialization code here.
        KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OAuth" accessGroup:nil];
        [wrapper setObject:@"OAuth" forKey:(__bridge id)kSecAttrAccount];
        [wrapper setObject:self.keychainItemName forKey:(__bridge id)kSecAttrService];
        self.accessTokenItem = wrapper;
        
        //fetch access token and expiration date from keychain and assign to facebook object
        NSArray *components = [[self.accessTokenItem objectForKey:@"v_Data"] componentsSeparatedByString:@"&"];
        
        if (1 < [components count]) {
            NSString *accessToken = [components objectAtIndex:0];
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateStyle:kCFDateFormatterFullStyle];
            NSDate *expirationDate = [dateFormat dateFromString:[components objectAtIndex:1]];
            
            if (accessToken) {
                self.facebook.accessToken = accessToken;
                self.facebook.expirationDate = expirationDate;
            }
        }
        
        // Initialization code here.
        NSDictionary *localUserDictionary = [self ioss_facebookUserDictionary];
        if (localUserDictionary) {
            self.userDictionary = localUserDictionary;
        }
    }
    
    return self;
}

- (id)initWithIdentifier:(NSString*)theIdentifier
{
    self = [super init];
    if (self) {

        self.identifier = theIdentifier;

        self.keychainItemName = [NSString stringWithFormat:@"%@-%@", [[FacebookService sharedService] serviceKeychainItemName], self.identifier];
        
        // Initialization code here.
        KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OAuth" accessGroup:nil];
        [wrapper setObject:@"OAuth" forKey:(__bridge id)kSecAttrAccount];
        [wrapper setObject:self.keychainItemName forKey:(__bridge id)kSecAttrService];
        self.accessTokenItem = wrapper;
        
        //fetch access token and expiration date from keychain and assign to facebook object
        NSArray *components = [[self.accessTokenItem objectForKey:@"v_Data"] componentsSeparatedByString:@"&"];
        
        if (1 < [components count]) {
            NSString *accessToken = [components objectAtIndex:0];
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateStyle:kCFDateFormatterFullStyle];
            NSDate *expirationDate = [dateFormat dateFromString:[components objectAtIndex:1]];
            
            if (accessToken) {
                self.facebook.accessToken = accessToken;
                self.facebook.expirationDate = expirationDate;
            }
        }
        
        // Initialization code here.
        NSDictionary *localUserDictionary = [self ioss_facebookUserDictionary];
        if (localUserDictionary) {
            self.userDictionary = localUserDictionary;
        }
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [self init];
    if (self) {

        //set the local user dictionary based on params that have been sent in
        self.facebook.accessToken = [dictionary objectForKey:@"access_token"];
        NSDecimalNumber *expiration = [dictionary objectForKey:@"access_token_expiration"];
        self.facebook.expirationDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[expiration doubleValue]];
        NSMutableDictionary *localUserDictionary = [NSMutableDictionary dictionary];
        [localUserDictionary setObject:[dictionary objectForKey:@"userId"] forKey:@"id"];
        [localUserDictionary setObject:[dictionary objectForKey:@"username"] forKey:@"username"];
        self.userDictionary = localUserDictionary;
    }
    return self;
}

- (void)setUserDictionary:(NSDictionary *)theUserDictionary
{
    if (theUserDictionary) {
        [super setUserDictionary:theUserDictionary];
        
        [self ioss_setFacebookUserDictionary:theUserDictionary];
    } else {
        iOSSLog(@"meh: no user dictionary");
    }
}

- (BOOL)isAuthenticated 
{
    /*
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* facebookCookies = [cookies cookiesForURL:[NSURL URLWithString:@"http://login.facebook.com"]];
    
    BOOL hasCookies = NO;
    if (0 < [facebookCookies count]) {
        hasCookies = YES;
    }

    if ((NO == [self.facebook isSessionValid]) && !hasCookies)
        return NO;
    */
    if (NO == [self.facebook isSessionValid])
        return NO;
    return YES;
}

- (void)fetchLocalUserDataWithCompletionHandler:(FetchUserDataHandler)completionHandler
{
    self.fetchUserDataHandler = completionHandler;

    //since they're logged in, fetch their details
    FBRequest *request = [self.facebook requestWithGraphPath:@"me" 
                                                 andDelegate:self];
    [self recordRequest:request withType:FBUserRequestType];
}

- (void)authenticateFromViewController:(UIViewController*)vc 
                 withCompletionHandler:(AuthenticationHandler)completionHandler;
{
    self.authenticationHandler = completionHandler;

    //cwnote: also see if permissions have changed!!!
    if (NO == [self isAuthenticated]) {

        if (nil == self.facebook) {
            self.facebook = [[Facebook alloc] initWithAppId:[[FacebookService sharedService] apiKey] 
                                            urlSchemeSuffix:[[FacebookService sharedService] urlSchemeSuffix]
                                                andDelegate:self];
        }
        
        //cwnote: need permissions!
        NSString *scope = [[FacebookService sharedService] apiScope];
        //create an array from space separated string components!!!
        NSArray *permissions = [scope componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [self.facebook authorize:permissions];
    } else {
        [self fetchLocalUserDataWithCompletionHandler:^(NSError *error) {
            if (!error) {
                //
            }
            
            if (self.authenticationHandler) {
                self.authenticationHandler(error);
                self.authenticationHandler = nil;
            }
        }];
    }

}

- (NSString*)oAuthAccessToken
{
    return self.facebook.accessToken;
}

- (NSTimeInterval)oAuthAccessTokenExpirationDate
{
    return [self.facebook.expirationDate timeIntervalSinceReferenceDate];
}

- (NSString*)oAuthAccessTokenSecret
{
    return nil;
}

- (void)logout
{
    [self.facebook logout:self];
    self.facebook = nil;
}

- (NSString*)userId
{
    return self.userID;
}

- (NSString*)username
{
    return self.alias;
}

- (NSString*)servicename
{
    return [FacebookService sharedService].name;
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    return [self.facebook handleOpenURL:url];
}

- (void)loadFriendsWithCompletionHandler:(FindFriendsHandler)completionHandler
{
    self.findFriendsHandler = completionHandler;

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"friends.getAppUsers" forKey:@"method"];

    //use the old REST api to get friends who use this app
    FBRequest *request = [self.facebook requestWithParams:params andDelegate:self];
    
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
    
    for (NSNumber *anIdentifier in identifiers) {
        NSString *path = [anIdentifier stringValue];
        FBRequest *request = [self.facebook requestWithGraphPath:path andDelegate:self];
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

    FBRequest *request = [self.facebook requestWithGraphPath:@"me/albums" 
                                                   andParams:dictionary 
                                               andHttpMethod:@"POST"
                                                 andDelegate:self];
    [self recordRequest:request withType:FBCreatePhotoAlbumRequestType];
}

- (void)loadPhotoAlbumsWithCompletionHandler:(LoadPhotoAlbumsHandler)completionHandler
{
    self.loadPhotoAlbumsHandler = completionHandler;

    FBRequest *request = [self.facebook requestWithGraphPath:@"me/albums" 
                                                 andDelegate:self];
    [self recordRequest:request withType:FBUserPhotoAlbumsRequestType];
}

- (void)postStatusUpdate:(NSMutableDictionary*)params 
   withCompletionHandler:(CompletionHandler)completionHandler
{
    self.genericCompletionHandler = completionHandler;
    
    //cwnote: need completion handler here so that I can tell caller and they can cleanup. ugh
    [self.facebook dialog:@"feed" 
                andParams:params 
              andDelegate:self];
}

#pragma mark -
#pragma mark FBSessionDelegate

- (void)fbDidLogin
{
    //save the access token and expiration date in the keychain for retrieval later when app starts. will be used to initialize facebook 
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:kCFDateFormatterFullStyle];
    NSString *date = [dateFormat stringFromDate:self.facebook.expirationDate];
    
    NSString *accessToken = [NSString stringWithFormat:@"%@&%@", self.facebook.accessToken, date];
    [self.accessTokenItem setObject:accessToken forKey:@"v_Data"];

    NSLog(@"fbDidLogin");
    
    [self fetchLocalUserDataWithCompletionHandler:^(NSError *error) {
        if (self.authenticationHandler) {
            self.authenticationHandler(error);
            self.authenticationHandler = nil;
        }
    }];
    
    //issue notification? UserAuthenticationDidChangeNotificationName
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    NSLog(@"fbDidNotLogin");

    if (self.authenticationHandler) {
        NSError *error = [NSError errorWithDomain:@"SW" code:1 userInfo:nil];
        self.authenticationHandler(error);
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
    
    [super request:request didFailWithError:error];
    
    switch (requestType) {
            
        case FBUserRequestType:
        {
            if (self.fetchUserDataHandler) {
                self.fetchUserDataHandler(error);
                self.fetchUserDataHandler = nil;
            }
        }
            break;
            
        case FBUserFriendsRequestType:
        {
             if (self.findFriendsHandler) {
                 self.findFriendsHandler(nil, error);
                 self.findFriendsHandler = nil;
             }
        }
            break;
            
        case FBUsersRequestType:
        {
            if (self.loadUsersHandler) {
                self.loadUsersHandler(nil, error);
                [users removeAllObjects];
                self.loadUsersHandler = nil;
            }
        }
            break;
            
        case FBCreatePhotoAlbumRequestType:
        {
            //call completion handler with error
            if (self.createPhotoAlbumHandler) {
                self.createPhotoAlbumHandler(error);
                self.createPhotoAlbumHandler = nil;
            }
        }
            break;
            
        case FBUserPhotoAlbumsRequestType:
        {
            //call completion handler with error
            if (self.loadPhotoAlbumsHandler) {
                self.loadPhotoAlbumsHandler(nil, error);
                self.loadPhotoAlbumsHandler = nil;
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    FBRequestType requestType = [self requestTypeForRequest:request];
    
    [super request:request didLoad:result];
    
    switch (requestType) {
            
        case FBUserRequestType:
        {
            NSDictionary *dictionary = (NSDictionary*)result;
            self.userDictionary = dictionary;
            
            if (self.fetchUserDataHandler) {
                self.fetchUserDataHandler(nil);
                self.fetchUserDataHandler = nil;
            }
        }
            break;
            
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
            FacebookUser *user = [[FacebookUser alloc] initWithDictionary:dictionary];
            
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
            /*
            NSDictionary *albumsDictionary = [(NSDictionary*)result objectForKey:@"data"];
            
            NSMutableArray *albums = [NSMutableArray array];
            for (NSDictionary *albumDictionary in albumsDictionary) {
                //create an album object for each
                FacebookPhotoAlbum *album = [[FacebookPhotoAlbum alloc] initWithDictionary:albumDictionary];
                //save the name and description of the album
                [albums addObject:album];
            }
            
            //call completion handler with error
            if (self.loadPhotoAlbumsHandler) {
                self.loadPhotoAlbumsHandler(albums, nil);
                self.loadPhotoAlbumsHandler = nil;
            }
            */
        }
            
        default:
            break;
    }
}

- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data
{
    [super request:request didLoadRawResponse:data];
}

/**
 * Called when the dialog succeeds and is about to be dismissed.
 */
- (void)dialogDidComplete:(FBDialog *)dialog
{
    if (nil != self.genericCompletionHandler) {
        self.genericCompletionHandler(nil);
        self.genericCompletionHandler = nil;
    }
}

/**
 * Called when the dialog succeeds with a returning url.
 */
- (void)dialogCompleteWithUrl:(NSURL *)url
{
    if (nil != self.genericCompletionHandler) {
        self.genericCompletionHandler(nil);
        self.genericCompletionHandler = nil;
    }
}

/**
 * Called when the dialog get canceled by the user.
 */
- (void)dialogDidNotCompleteWithUrl:(NSURL *)url
{
    if (nil != self.genericCompletionHandler) {
        self.genericCompletionHandler(nil);
        self.genericCompletionHandler = nil;
    }
}

/**
 * Called when the dialog is cancelled and is about to be dismissed.
 */
- (void)dialogDidNotComplete:(FBDialog *)dialog
{
    if (nil != self.genericCompletionHandler) {
        self.genericCompletionHandler(nil);
        self.genericCompletionHandler = nil;
    }
}

/**
 * Called when dialog failed to load due to an error.
 */
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error
{
    if (nil != self.genericCompletionHandler) {
        self.genericCompletionHandler(error);
        self.genericCompletionHandler = nil;
    }
}

/**
 * Asks if a link touched by a user should be opened in an external browser.
 *
 * If a user touches a link, the default behavior is to open the link in the Safari browser,
 * which will cause your app to quit.  You may want to prevent this from happening, open the link
 * in your own internal browser, or perhaps warn the user that they are about to leave your app.
 * If so, implement this method on your delegate and return NO.  If you warn the user, you
 * should hold onto the URL and once you have received their acknowledgement open the URL yourself
 * using [[UIApplication sharedApplication] openURL:].
 */
- (BOOL)dialog:(FBDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL *)url
{
    return NO;
}

@end
