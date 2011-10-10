//
//  LocalInstagramUser.h
//  InstaBeta
//
//  Created by Christopher White on 7/14/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "InstagramUser.h"
#import "iOSSocialServiceOAuth2ProviderConstants.h"
#import "iOSSocialLocalUser.h"

@class InstagramMediaCollection;

typedef void(^FetchMediaHandler)(NSDictionary *dictionary, NSError *error);

@class InstagramUserCollection;

typedef void(^FetchUsersHandler)(NSArray *users, NSError *error);

typedef void(^InstagramAuthenticationHandler)(NSError *error);


@interface LocalInstagramUser : InstagramUser <iOSSocialLocalUserProtocol>

// Obtain the LocalInstagramUser object.
// The user is only available for offline use until logged in.
// A temporary use is created if no account is set up.
+ (LocalInstagramUser *)localInstagramUser;

@property(nonatomic, readonly, getter=isAuthenticated)  BOOL authenticated; // Authentication state

// Authenticate the user for access to user details. This may present a UI to the user if necessary to login or create an account. 
// The user must be authenticated in order to use other APIs. 
// This should be called for each launch of the application as soon as the UI is ready.
// Authentication happens automatically on return to foreground, and the completion handler will be called again. 
// Instagram UI may be presented during this authentication. 
// Apps should check the local user's authenticated and user ID properties to determine if the local user has changed.
// The authorization screen, if needed, is show modally so pass in the current view controller.
// Possible reasons for error:
// 1. Communications problem
// 2. User credentials invalid
// 3. User cancelled
- (void)authenticateFromViewController:(UIViewController*)vc 
                 withCompletionHandler:(AuthenticationHandler)completionHandler;

- (NSString*)oAuthAccessToken;

- (NSTimeInterval)oAuthAccessTokenExpirationDate;

- (NSString*)oAuthAccessTokenSecret;

//remove all stored OAuth info from the keychain and reset state in memory
- (void)logout;

- (void)fetchRelationshipToUser;

- (void)fetchRequestedBy;

- (void)modifyRelationshipToUser;

// These methods make it easy to interact with the instagram app on the user's device.
+ (void)instagram;
+ (void)camera;
+ (void)tagWithName:(NSString*)name;
+ (void)userWithName:(NSString*)name; 
+ (void)locationWithID:(NSString*)locationID;
+ (void)mediaWithID:(NSString*)mediaID;
+ (void)editPhotoWithURL:(NSURL*)url 
         andMenuFromView:(UIView*)view;

- (void)fetchUserDataWithCompletionHandler:(FetchUserDataHandler)completionHandler;

- (void)fetchRecentMediaWithCompletionHandler:(FetchMediaHandler)completionHandler;

@end
