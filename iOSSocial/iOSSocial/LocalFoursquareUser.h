//
//  LocalFoursquareUser.h
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FoursquareUser.h"
#import "iOSSocialServiceOAuth2ProviderConstants.h"

typedef void(^FoursquareAuthenticationHandler)(NSError *error);

@interface LocalFoursquareUser : FoursquareUser

// Obtain the LocalFoursquareUser object.
// The user is only available for offline use until logged in.
// A temporary use is created if no account is set up.
+ (LocalFoursquareUser *)localFoursquareUser;

// This must be called before calling any of the non-class methods on localFoursquareUser otherwise it will cause an assertion
// See iOSSocialServiceOAuth2ProviderConstants.h for the Keys for this dictionary.
- (void)assignOAuthParams:(NSDictionary*)params;

@property(nonatomic, readonly, getter=isAuthenticated)  BOOL authenticated; // Authentication state

// Authenticate the user for access to user details. This may present a UI to the user if necessary to login or create an account. 
// The user must be authenticated in order to use other APIs. 
// This should be called for each launch of the application as soon as the UI is ready.
// Authentication happens automatically on return to foreground, and the completion handler will be called again. 
// Foursquare UI may be presented during this authentication. 
// Apps should check the local user's authenticated and user ID properties to determine if the local user has changed.
// The authorization screen, if needed, is show modally so pass in the current view controller.
// Possible reasons for error:
// 1. Communications problem
// 2. User credentials invalid
// 3. User cancelled
- (void)authenticateWithScope:(NSString*)scope 
           fromViewController:(UIViewController*)vc 
        withCompletionHandler:(FoursquareAuthenticationHandler)completionHandler;

- (NSString*)oAuthAccessToken;

//remove all stored OAuth info from the keychain and reset state in memory
- (void)logout;

@end
