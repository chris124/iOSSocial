//
//  iOSSocialLocalUser.m
//  iOSSocial
//
//  Created by Christopher White on 7/26/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "iOSSocialLocalUser.h"

@interface iOSSocialLocalUser () 

@property(nonatomic, copy)      AuthenticationHandler authenticationHandler;
//@property(nonatomic, retain)    Instagram *instagram; //cwnote: make parent class for services? factory?

@end

@implementation iOSSocialLocalUser

@synthesize authenticated;
@synthesize authenticationHandler;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)assignOAuthParams:(NSDictionary*)params
{
    //self.instagram = [[Instagram alloc] initWithDictionary:params];
}

- (BOOL)isAuthenticated
{
    //assert if instagram is nil. params have not been set!
    
    //if (NO == [self.instagram isSessionValid])
    //    return NO;
    return YES;
}

- (void)authenticateWithScope:(NSString*)scope 
           fromViewController:(UIViewController*)vc 
        withCompletionHandler:(AuthenticationHandler)completionHandler
{
    //assert if instagram is nil. params have not been set!
    
    //cwnote: also see if permissions have changed!!!
    if (NO == [self isAuthenticated]) {
        
        self.authenticationHandler = completionHandler;
        
        /*
        [self.instagram authorizeWithScope:scope 
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
         */
    } else {
        //[self fetchLocalUserDataWithCompletionHandler:nil];
    }

}

- (NSString*)oAuthAccessToken
{
    //return [self.instagram oAuthAccessToken];
    return nil;
}

//remove all stored OAuth info from the keychain and reset state in memory
- (void)logout
{
    //[self.instagram logout];
}

@end
