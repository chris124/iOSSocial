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
#import "FlickrUser.h"
#import "iOSSocialServiceOAuth1ProviderConstants.h"
#import "iOSSocialLocalUser.h"

typedef void(^FlickrAuthenticationHandler)(NSError *error);
typedef void(^PostPhotoDataHandler)(NSString *photoID, NSError *error);
typedef void(^PhotoInfoDataHandler)(NSDictionary *photoInfo, NSError *error);
typedef void(^UserPhotosDataHandler)(NSDictionary *photos, NSError *error);
typedef void(^PhotoSizesDataHandler)(NSDictionary *photoInfo, NSError *error);

@interface LocalFlickrUser : FlickrUser <iOSSocialLocalUserProtocol, NSXMLParserDelegate> 

// Obtain the LocalFlickrUser object.
// The user is only available for offline use until logged in.
// A temporary use is created if no account is set up.
+ (LocalFlickrUser *)localFlickrUser;

@property(nonatomic, readonly, getter=isAuthenticated)  BOOL authenticated; // Authentication state

// Authenticate the user for access to user details. This may present a UI to the user if necessary to login or create an account. 
// The user must be authenticated in order to use other APIs. 
// This should be called for each launch of the application as soon as the UI is ready.
// Authentication happens automatically on return to foreground, and the completion handler will be called again. 
// Flickr UI may be presented during this authentication. 
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

- (void)getUserPhotosWithCompletionHandler:(UserPhotosDataHandler)completionHandler;

- (void)postPhotoData:(NSData*)imageData 
         withFileName:(NSString *)fileName 
            andParams:(NSDictionary*)photoParams 
 andCompletionHandler:(PostPhotoDataHandler)completionHandler;

- (void)getInfoForPhotoWithId:(NSString*)photoID andCompletionHandler:(PhotoInfoDataHandler)completionHandler;
- (void)getPhotoSizesForPhotoWithId:(NSString*)photoID andCompletionHandler:(PhotoSizesDataHandler)completionHandler;

@end
