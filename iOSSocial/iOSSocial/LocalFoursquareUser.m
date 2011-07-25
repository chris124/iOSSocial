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

static LocalFoursquareUser *localFoursquareUser = nil;

@interface LocalFoursquareUser () 

@property(nonatomic, copy)      FoursquareAuthenticationHandler authenticationHandler;
@property(nonatomic, retain)    Foursquare *foursquare;

@end

@implementation LocalFoursquareUser

@synthesize authenticated;
@synthesize authenticationHandler;
@synthesize foursquare;

+ (LocalFoursquareUser *)localFoursquareUser
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

- (void)fetchLocalUserDataWithCompletionHandler:(FetchFoursquareUserDataHandler)completionHandler
{
    /*
    self.fetchUserDataHandler = completionHandler;
    
    NSString *urlString = @"https://api.instagram.com/v1/users/self/";
    NSURL *url = [NSURL URLWithString:urlString];
    
    IGRequest *request = [[IGRequest alloc] initWithURL:url  
                                             parameters:nil 
                                          requestMethod:IGRequestMethodGET];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            if (self.fetchUserDataHandler) {
                self.fetchUserDataHandler(error);
                self.fetchUserDataHandler = nil;
            }
        } else {
            NSDictionary *dictionary = [Instagram JSONFromData:responseData];
            self.userDictionary = dictionary;
            
            if (self.fetchUserDataHandler) {
                self.fetchUserDataHandler(nil);
                self.fetchUserDataHandler = nil;
            }
        }
    }];
    */
}

- (void)authenticateWithScope:(NSString*)scope 
           fromViewController:(UIViewController*)vc 
        withCompletionHandler:(FoursquareAuthenticationHandler)completionHandler
{
    //assert if foursquare is nil. params have not been set!
    
    //cwnote: also see if permissions have changed!!!
    if (NO == [self isAuthenticated]) {
        
        self.authenticationHandler = completionHandler;
        
        [self.foursquare authorizeWithScope:scope 
                        fromViewController:vc withCompletionHandler:^(NSDictionary *userInfo, NSError *error) {
                            if (error) {
                                
                            } else {
                                NSDictionary *user = [userInfo objectForKey:@"user"];
                                self.userDictionary = user;
                            }
                            
                            if (self.authenticationHandler) {
                                self.authenticationHandler(error);
                                self.authenticationHandler = nil;
                            }
                        }];
    } else {
        [self fetchLocalUserDataWithCompletionHandler:nil];
    }
}

- (void)logout
{
    //assert if foursquare is nil. params have not been set!
    
    [self.foursquare logout];
}

@end
