//
//  LocalTwitterUser.m
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "LocalTwitterUser.h"
#import "Twitter.h"
#import "TwitterUser+Private.h"
#import "NSUserDefaults+iOSSAdditions.h"

static LocalTwitterUser *localTwitterUser = nil;

@interface LocalTwitterUser () 

@property(nonatomic, copy)      TwitterAuthenticationHandler authenticationHandler;
@property(nonatomic, retain)    Twitter *twitter;

@end

@implementation LocalTwitterUser

@synthesize authenticated;
@synthesize authenticationHandler;
@synthesize twitter;

+ (LocalTwitterUser *)localTwitterUser
{
    @synchronized(self) {
        if(localTwitterUser == nil)
            localTwitterUser = [[super allocWithZone:NULL] init];
    }
    return localTwitterUser;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        NSDictionary *localUserDictionary = [[NSUserDefaults standardUserDefaults] ioss_twitterUserDictionary];
        if (localUserDictionary) {
            self.userDictionary = localUserDictionary;
        }
    }
    
    return self;
}

- (void)setUserDictionary:(NSDictionary *)theUserDictionary
{
    [super setUserDictionary:theUserDictionary];
    
    [[NSUserDefaults standardUserDefaults] ioss_setTwitterUserDictionary:theUserDictionary];
}

- (void)assignOAuthParams:(NSDictionary*)params
{
    self.twitter = [[Twitter alloc] initWithDictionary:params];
}

- (BOOL)isAuthenticated
{
    //assert if instagram is nil. params have not been set!
    if (NO == [self.twitter isSessionValid])
        return NO;
    return YES;
}

- (void)fetchLocalUserDataWithCompletionHandler:(FetchTwitterUserDataHandler)completionHandler
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
        withCompletionHandler:(TwitterAuthenticationHandler)completionHandler
{
    //assert if instagram is nil. params have not been set!
    
    //cwnote: also see if permissions have changed!!!
    if (NO == [self isAuthenticated]) {
        
        self.authenticationHandler = completionHandler;

        [self.twitter authorizeWithScope:scope 
                      fromViewController:vc 
                   withCompletionHandler:^(NSDictionary *userInfo, NSError *error) {
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

- (NSString*)oAuthAccessToken
{
    return [self.twitter oAuthAccessToken];
}

- (void)logout
{
    //assert if instagram is nil. params have not been set!
    
    [self.twitter logout];
}

@end
