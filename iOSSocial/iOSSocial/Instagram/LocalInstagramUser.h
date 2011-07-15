//
//  LocalInstagramUser.h
//  InstaBeta
//
//  Created by Christopher White on 7/14/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^AuthenticationHandler)(NSError *error);

@interface LocalInstagramUser : NSObject

// Obtain the LocalInstagramUser object.
// The user is only available for offline use until logged in.
// A temporary use is created if no account is set up.
+ (LocalInstagramUser *)localInstagramUser;

@property(nonatomic, readonly, getter=isAuthenticated)  BOOL authenticated; // Authentication state

// Authenticate the user for access to user details. This may present UI to the user if necessary to login or create an account. The user must be authenticated in order to use other APIs. This should be called for each launch of the application as soon as the UI is ready.
// Authentication happens automatically on return to foreground, and the completion handler will be called again. Instagram UI may be presented during this authentication. Apps should check the local user's authenticated and user ID properties to determine if the local user has changed.
// Possible reasons for error:
// 1. Communications problem
// 2. User credentials invalid
// 3. User cancelled
- (void)authenticateUserPermissions:(NSArray*)permissions 
                 fromViewController:(UIViewController*)vc 
              withCompletionHandler:(AuthenticationHandler)completionHandler;

- (void)logout;

@end
