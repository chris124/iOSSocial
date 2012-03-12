/*
 * Copyright 2011 Mad Races, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "iOSSocialConstants.h"

typedef void(^AuthenticationHandler)(NSError *error);

@protocol iOSSocialLocalUserProtocol <NSObject>

@required

- (id)initWithDictionary:(NSDictionary*)dictionary;

- (id)initWithIdentifier:(NSString*)identifier;

@property(nonatomic, readonly, getter=isAuthenticated)  BOOL authenticated; // Authentication state

@property(nonatomic, readonly, retain)  NSString *username;
@property(nonatomic, readonly, retain)  NSString *servicename;
@property(nonatomic, readonly, retain)  NSString *identifier;
@property(nonatomic, readonly, retain)  NSString *profilePictureURL;

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
- (UIViewController*)authenticateFromViewController:(UIViewController*)vc 
                              withCompletionHandler:(AuthenticationHandler)completionHandler;

- (NSString*)oAuthAccessToken;

- (NSTimeInterval)oAuthAccessTokenExpirationDate;

- (NSString*)oAuthAccessTokenSecret;

//remove all stored OAuth info from the keychain and reset state in memory
- (void)logout;

- (NSString*)userId;

- (void)loadPhotoWithCompletionHandler:(LoadPhotoHandler)completionHandler;

@optional

- (NSURL*)authorizedURL:(NSURL*)theURL;

@end
