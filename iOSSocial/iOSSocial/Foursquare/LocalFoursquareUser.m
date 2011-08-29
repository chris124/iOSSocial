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

+ (id<iOSSocialLocalUserProtocol>)localUser
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

- (id)init
{
    self = [super init];
    if (self) {
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef uuidStr = CFUUIDCreateString(kCFAllocatorDefault, uuid);
        self.uuidString = (__bridge NSString *)uuidStr;
        CFRelease(uuidStr);
        CFRelease(uuid); 
        
        self.keychainItemName = [NSString stringWithFormat:@"InstaBeta_Foursquare_Service-%@", self.uuidString];
        self.auth = [[Foursquare sharedService] checkAuthenticationForKeychainItemName:self.keychainItemName];
        
        // Initialization code here.
        NSDictionary *localUserDictionary = [self ioss_foursquareUserDictionary];
        if (localUserDictionary) {
            self.userDictionary = localUserDictionary;
        }
    }
    
    return self;
}

- (id)initWithUUID:(NSString*)uuid
{
    self = [super init];
    if (self) {
        self.uuidString = uuid;
        
        self.keychainItemName = [NSString stringWithFormat:@"InstaBeta_Foursquare_Service-%@", self.uuidString];
        self.auth = [[Foursquare sharedService] checkAuthenticationForKeychainItemName:self.keychainItemName];
        
        // Initialization code here.
        NSDictionary *localUserDictionary = [self ioss_foursquareUserDictionary];
        if (localUserDictionary) {
            self.userDictionary = localUserDictionary;
        }
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
    [super setUserDictionary:theUserDictionary];
    
    [self ioss_setFoursquareUserDictionary:theUserDictionary];
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
    //assert if foursquare is nil. params have not been set!
    
    self.authenticationHandler = completionHandler;
    
    //cwnote: also see if permissions have changed!!!
    if (NO == [self isAuthenticated]) {

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
                    if (!error) {
                        //
                        [[iOSSocialServicesStore sharedServiceStore] registerAccount:self];
                    }
                    
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

- (void)logout
{
    [[Foursquare sharedService] logout:self.auth forKeychainItemName:self.keychainItemName];
    
    self.auth = nil;
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
