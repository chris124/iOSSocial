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
#import "TwitterRequest.h"

static LocalTwitterUser *localTwitterUser = nil;

@interface LocalTwitterUser () 

@property(nonatomic, copy)      TwitterAuthenticationHandler authenticationHandler;
@property(nonatomic, retain)    Twitter *twitter;
@property(nonatomic, readwrite, retain)  NSString *scope;

@end

@implementation LocalTwitterUser

@synthesize authenticated;
@synthesize authenticationHandler;
@synthesize twitter;
@synthesize scope;

+ (LocalTwitterUser *)localTwitterUser
{
    @synchronized(self) {
        if(localTwitterUser == nil)
            localTwitterUser = [[super allocWithZone:NULL] init];
    }
    return localTwitterUser;
}

+ (id<iOSSocialLocalUserProtocol>)localUser
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
    
    self.scope = [params objectForKey:@"scope"];
}

- (BOOL)isAuthenticated
{
    //assert if instagram is nil. params have not been set!
    if (NO == [self.twitter isSessionValid])
        return NO;
    return YES;
}

- (void)fetchLocalUserDataWithCompletionHandler:(FetchUserDataHandler)completionHandler
{
    //GET users/show
    //https://dev.twitter.com/docs/api/1/get/users/show

    self.fetchUserDataHandler = completionHandler;
    
    //cwnote: fix this url!! dev.twitter.com is down. ugh.
    NSString *urlString = @"https://api.instagram.com/v1/users/self/";
    NSURL *url = [NSURL URLWithString:urlString];
    
    TwitterRequest *request = [[TwitterRequest alloc] initWithURL:url  
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
            NSDictionary *dictionary = [Twitter JSONFromData:responseData];
            self.userDictionary = dictionary;
            
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
    //assert if twitter is nil. params have not been set!
    
    self.authenticationHandler = completionHandler;
    
    //cwnote: also see if permissions have changed!!!
    if (NO == [self isAuthenticated]) {

        [self.twitter authorizeWithScope:self.scope 
                      fromViewController:vc 
                   withCompletionHandler:^(NSDictionary *userInfo, NSError *error) {
                            if (error) {
                                if (self.authenticationHandler) {
                                    self.authenticationHandler(error);
                                    self.authenticationHandler = nil;
                                }
                            } else {
                                NSDictionary *user = [userInfo objectForKey:@"user"];
                                self.userDictionary = user;
                                
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
    //assert if twitter is nil. params have not been set!
    
    return [self.twitter oAuthAccessToken];
}

- (void)logout
{
    //assert if twitter is nil. params have not been set!
    
    [self.twitter logout];
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
