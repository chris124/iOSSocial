//
//  LocalFoursquareUser.m
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "LocalFoursquareUser.h"
#import "Foursquare.h"
#import "FoursquareUser+Private.h"
#import "iOSSRequest.h"
#import "GTMOAuth2Authentication.h"
#import "iOSSLog.h"


NSString *const iOSSDefaultsKeyFoursquareUserDictionary = @"ioss_foursquareUserDictionary";

static LocalFoursquareUser *localFoursquareUser = nil;

@interface LocalFoursquareUser () 

@property(nonatomic, copy)      FoursquareAuthenticationHandler authenticationHandler;
@property(nonatomic, retain)    GTMOAuth2Authentication *auth;
@property(nonatomic, retain)    NSString *keychainItemName;
@property(nonatomic, retain)    NSString *uuidString;

@end

@implementation LocalFoursquareUser

@synthesize authenticated;
@synthesize authenticationHandler;
@synthesize username;
@synthesize servicename;
@synthesize auth;
@synthesize keychainItemName;
@synthesize uuidString;

+ (LocalFoursquareUser *)localFoursquareUser
{
    @synchronized(self) {
        if(localFoursquareUser == nil)
            localFoursquareUser = [[super allocWithZone:NULL] init];
    }
    return localFoursquareUser;
}

- (NSDictionary *)ioss_foursquareUserDictionary 
{ 
    return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-%@", iOSSDefaultsKeyFoursquareUserDictionary, self.uuidString]];
}

- (void)ioss_setFoursquareUserDictionary:(NSDictionary *)theUserDictionary 
{ 
    [[NSUserDefaults standardUserDefaults] setObject:theUserDictionary forKey:[NSString stringWithFormat:@"%@-%@", iOSSDefaultsKeyFoursquareUserDictionary, self.uuidString]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)commonInit:(NSString*)theUuid
{
    if (theUuid) {
        self.uuidString = theUuid;
    } else {
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef uuidStr = CFUUIDCreateString(kCFAllocatorDefault, uuid);
        self.uuidString = (__bridge NSString *)uuidStr;
        CFRelease(uuidStr);
        CFRelease(uuid);
    }
    
    
    self.keychainItemName = [NSString stringWithFormat:@"%@-%@", [[Foursquare sharedService] serviceKeychainItemName], self.uuidString];
    self.auth = [[Foursquare sharedService] checkAuthenticationForKeychainItemName:self.keychainItemName];
    
    // Initialization code here.
    NSDictionary *localUserDictionary = [self ioss_foursquareUserDictionary];
    if (localUserDictionary) {
        self.userDictionary = localUserDictionary;
    }
}

- (void)reset
{
    self.auth = nil;
    self.uuidString = nil;
    self.keychainItemName = nil;
    self.userDictionary = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit:nil];
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [self init];
    if (self) {
        //set the local user dictionary based on params that have been sent in
        self.auth.accessToken = [dictionary objectForKey:@"access_token"];
        NSMutableDictionary *localUserDictionary = [NSMutableDictionary dictionary];
        //[localUserDictionary setObject:[dictionary objectForKey:@"userId"] forKey:@"id"];
        //[localUserDictionary setObject:[dictionary objectForKey:@"username"] forKey:@"username"];
        
        /*
        NSDictionary *responseDict = [theUserDictionary objectForKey:@"response"];
        if (responseDict) {
            NSDictionary *userDict = [responseDict objectForKey:@"user"];
            if (userDict) {
                self.userID = [userDict objectForKey:@"id"];
                self.alias = [userDict objectForKey:@"firstName"];
                self.firstName = [userDict objectForKey:@"firstName"];
                self.profilePictureURL = [userDict objectForKey:@"photo"];
            }
        }
        */
        NSMutableDictionary *responseDict = [NSMutableDictionary dictionary];
        NSMutableDictionary *userDict = [NSMutableDictionary dictionary];
        [userDict setObject:[dictionary objectForKey:@"userId"] forKey:@"id"];
        [userDict setObject:[dictionary objectForKey:@"username"] forKey:@"firstName"];
        [responseDict setObject:userDict forKey:@"user"];
        [localUserDictionary setObject:responseDict forKey:@"response"];
        
        self.userDictionary = localUserDictionary;
    }
    return self;
}

- (id)initWithUUID:(NSString*)uuid
{
    self = [super init];
    if (self) {
        [self commonInit:uuid];
    }
    
    return self;
}

- (BOOL)isAuthenticated
{
    if (NO == self.auth.canAuthorize)
        return NO;
    return YES;
}

- (void)setUserDictionary:(NSDictionary *)theUserDictionary
{
    if (theUserDictionary) {
        [super setUserDictionary:theUserDictionary];
        
        [self ioss_setFoursquareUserDictionary:theUserDictionary];
    } else {
        iOSSLog(@"meh: no user dictionary");
    }
}

- (NSURL*)authorizedURL:(NSURL*)theURL
{
    NSString *access_token = [NSString stringWithFormat:@"?oauth_token=%@", [self oAuthAccessToken]];
    NSURL *url = [NSURL URLWithString:access_token relativeToURL:theURL];
    
    return url;
}

- (void)fetchLocalUserDataWithCompletionHandler:(FetchUserDataHandler)completionHandler
{    
    //response https://developer.foursquare.com/docs/responses/user.html

    self.fetchUserDataHandler = completionHandler;
    
    //cwnote: can specify user id instead of self.
    NSString *urlString = @"https://api.foursquare.com/v2/users/self";
    NSURL *url = [self authorizedURL:[NSURL URLWithString:urlString]];
    
    iOSSRequest *request = [[iOSSRequest alloc] initWithURL:url  
                                                 parameters:nil 
                                              requestMethod:iOSSRequestMethodGET];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            if (self.fetchUserDataHandler) {
                self.fetchUserDataHandler(error);
                self.fetchUserDataHandler = nil;
            }
        } else {

            if (responseData) {
                NSDictionary *dictionary = [Foursquare JSONFromData:responseData];
                self.userDictionary = dictionary;
            }

            if (self.fetchUserDataHandler) {
                self.fetchUserDataHandler(nil);
                self.fetchUserDataHandler = nil;
            }
        }
    }];
}

- (void)authenticateFromViewController:(UIViewController*)vc 
                 withCompletionHandler:(AuthenticationHandler)completionHandler;
{
    self.authenticationHandler = completionHandler;
    
    //cwnote: also see if permissions have changed!!!
    if (NO == [self isAuthenticated]) {
        
        if (nil == self.auth) {
            [self commonInit:nil];
        }

        [[Foursquare sharedService] authorizeFromViewController:vc 
                                                        forAuth:self.auth 
                                            andKeychainItemName:self.keychainItemName 
                                                andCookieDomain:@"foursquare.com" 
                                          withCompletionHandler:^(GTMOAuth2Authentication *theAuth, NSDictionary *userInfo, NSError *error) {
            
            self.auth = theAuth;
            if (error) {
                if (self.authenticationHandler) {
                    self.authenticationHandler(error);
                    self.authenticationHandler = nil;
                }
            } else {
                [self fetchLocalUserDataWithCompletionHandler:^(NSError *error) {
                    if (self.authenticationHandler) {
                        self.authenticationHandler(error);
                        self.authenticationHandler = nil;
                    }
                }];
            }
        }];
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
    return self.auth.accessToken;
}

- (NSTimeInterval)oAuthAccessTokenExpirationDate
{
    return 0.0;
}

- (NSString*)oAuthAccessTokenSecret
{
    return nil;
}

- (void)logout
{
    [[Foursquare sharedService] logout:self.auth forKeychainItemName:self.keychainItemName];
    
    [self reset];
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
    return [Foursquare sharedService].name;
}

@end
