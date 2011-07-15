//
//  LocalInstagramUser.m
//  InstaBeta
//
//  Created by Christopher White on 7/14/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "LocalInstagramUser.h"
#import "SocialManager.h"
#import "Instagram.h"

static LocalInstagramUser *localInstagramUser = nil;

@interface LocalInstagramUser () 

@property(nonatomic, copy)              AuthenticationHandler authenticationHandler;

@end

@implementation LocalInstagramUser

@synthesize authenticated;
@synthesize authenticationHandler;

+ (LocalInstagramUser *)localInstagramUser
{
    @synchronized(self) {
        if(localInstagramUser == nil)
            localInstagramUser = [[super allocWithZone:NULL] init];
    }
    return localInstagramUser;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (BOOL)isAuthenticated 
{
    if (NO == [[SocialManager socialManager].instagram isSessionValid])
        return NO;
    return YES;
}

- (void)fetchLocalUserData
{
    //have to authenticate the request. ugh.!!!!
    /*
    //since they're logged in, fetch their details
    FBRequest *request = [[SocialManager socialManager].instagram requestWithGraphPath:@"me" 
                                                                          andDelegate:self];
    [self recordRequest:request withType:FBUserRequestType];
    */
}

- (void)authenticateWithScope:(NSString*)scope 
                 fromViewController:(UIViewController*)vc
              withCompletionHandler:(AuthenticationHandler)completionHandler
{
    //cwnote: also see if permissions have changed!!!
    if (NO == [self isAuthenticated]) {
        
        self.authenticationHandler = completionHandler;
        
        [[SocialManager socialManager].instagram authorizeWithScope:scope 
                                        fromViewController:vc];
        
        //[[SocialManager socialManager].instagram authorize:permissions 
                                                    //delegate:self];
    } else {
        [self fetchLocalUserData];
    }
}

- (void)logout
{
    [[SocialManager socialManager].instagram logout];
}

@end
