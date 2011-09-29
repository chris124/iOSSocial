//
//  iOSSocialLocalUser.h
//  iOSSocial
//
//  Created by Christopher White on 7/26/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "iOSSocialConstants.h"

typedef void(^AuthenticationHandler)(NSError *error);

@protocol iOSSocialLocalUserProtocol <NSObject>

- (id)initWithDictionary:(NSDictionary*)dictionary;

- (id)initWithUUID:(NSString*)uuid;

@property(nonatomic, readonly, getter=isAuthenticated)  BOOL authenticated; // Authentication state

@property(nonatomic, readonly, retain)  NSString *username;
@property(nonatomic, readonly, retain)  NSString *servicename;
@property(nonatomic, readonly, retain)  NSString *uuidString;

// Authenticate the user for access to user details. This may present a UI to the user if necessary to login or create an account. 
// The user must be authenticated in order to use some other APIs (on a per-service basis). 
// This should be called for each launch of the application as soon as the UI is ready.
// Authentication happens automatically on return to foreground, and the completion handler will be called again. 
// The UI may be presented during this authentication. 
// Apps should check the local user's authenticated and user ID properties to determine if the local user has changed.
// The authorization screen, if needed, is show modally so pass in the current view controller.
// Possible reasons for error:
// 1. Communications problem
// 2. User credentials invalid
// 3. User cancelled
- (void)authenticateFromViewController:(UIViewController*)vc 
                 withCompletionHandler:(AuthenticationHandler)completionHandler;

- (NSString*)oAuthAccessToken;

- (NSString*)oAuthAccessTokenSecret;

//remove all stored OAuth info from the keychain and reset state in memory
- (void)logout;

- (NSString*)userId;

- (void)loadPhotoWithCompletionHandler:(LoadPhotoHandler)completionHandler;

- (NSURL*)authorizedURL:(NSURL*)theURL;

@end
