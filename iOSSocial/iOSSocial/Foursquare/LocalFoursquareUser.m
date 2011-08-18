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
#import "NSUserDefaults+iOSSAdditions.h"
#import "FoursquareRequest.h"

static LocalFoursquareUser *localFoursquareUser = nil;

@interface LocalFoursquareUser () 

@property(nonatomic, copy)      FoursquareAuthenticationHandler authenticationHandler;
@property(nonatomic, retain)    Foursquare *foursquare;
@property(nonatomic, readwrite, retain)  NSString *scope;

@end

@implementation LocalFoursquareUser

@synthesize authenticated;
@synthesize authenticationHandler;
@synthesize foursquare;
@synthesize scope;

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

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        NSDictionary *localUserDictionary = [[NSUserDefaults standardUserDefaults] ioss_foursquareUserDictionary];
        if (localUserDictionary) {
            self.userDictionary = localUserDictionary;
        }
    }
    
    return self;
}

- (void)assignOAuthParams:(NSDictionary*)params
{
    self.foursquare = [[Foursquare alloc] initWithDictionary:params];
    
    self.scope = [params objectForKey:@"scope"];
}

- (BOOL)isAuthenticated
{
    //assert if foursquare is nil. params have not been set!
    
    if (NO == [self.foursquare isSessionValid])
        return NO;
    return YES;
}

- (void)setUserDictionary:(NSDictionary *)theUserDictionary
{
    [super setUserDictionary:theUserDictionary];
    
    [[NSUserDefaults standardUserDefaults] ioss_setFoursquareUserDictionary:theUserDictionary];
}

- (void)fetchLocalUserDataWithCompletionHandler:(FetchUserDataHandler)completionHandler
{    
    //response https://developer.foursquare.com/docs/responses/user.html

    self.fetchUserDataHandler = completionHandler;
    
    //cwnote: can specify user id instead of self.
    NSString *urlString = @"https://api.foursquare.com/v2/users/self";
    NSURL *url = [NSURL URLWithString:urlString];
    
    FoursquareRequest *request = [[FoursquareRequest alloc] initWithURL:url  
                                                             parameters:nil 
                                                          requestMethod:iOSSRequestMethodGET];
    
    request.requiresAuthentication = YES;
    
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

        [self.foursquare authorizeWithScope:self.scope 
                        fromViewController:vc withCompletionHandler:^(NSDictionary *userInfo, NSError *error) {
                            if (error) {
                                if (self.authenticationHandler) {
                                    self.authenticationHandler(error);
                                    self.authenticationHandler = nil;
                                }
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
    //assert if foursquare is nil. params have not been set!
    
    return [self.foursquare oAuthAccessToken];
}

- (void)logout
{
    //assert if foursquare is nil. params have not been set!
    
    [self.foursquare logout];
}

- (NSString*)userId
{
    return self.userID;
}

- (NSString*)username
{
    return self.alias;
}

@end
