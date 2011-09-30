//
//  LocalFacebookUser.h
//  MadRaces
//
//  Created by Christopher White on 7/5/11.
//  Copyright 2011 Betaworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookUser.h"
#import "iOSSocialLocalUser.h"


//typedef void(^AuthenticationHandler)(NSError *error);
typedef void(^FindFriendsHandler)(NSArray *friends, NSError *error);
typedef void(^LoadUsersHandler)(NSArray *users, NSError *error);
typedef void(^CreatePhotoAlbumHandler)(NSError *error);
typedef void(^LoadPhotoAlbumsHandler)(NSArray *photoAlbums, NSError *error);

@interface LocalFacebookUser : FacebookUser <iOSSocialLocalUserProtocol> {
}

// Obtain the LocalFacebookUser object.
// The user is only available for offline use until logged in.
// A temporary use is created if no account is set up.
+ (LocalFacebookUser *)localFacebookUser;

@property(nonatomic, readonly, getter=isAuthenticated)  BOOL authenticated; // Authentication state
/*
// Authenticate the user for access to user details. This may present UI to the user if necessary to login or create an account. The user must be authenticated in order to use other APIs. This should be called for each launch of the application as soon as the UI is ready.
// Authentication happens automatically on return to foreground, and the completion handler will be called again. Facebook UI may be presented during this authentication. Apps should check the local user's authenticated and user ID properties to determine if the local user has changed.
// Possible reasons for error:
// 1. Communications problem
// 2. User credentials invalid
// 3. User cancelled
- (void)authenticateUserPermissions:(NSArray*)permissions 
              withCompletionHandler:(AuthenticationHandler)completionHandler;
*/
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

- (NSString*)oAuthAccessTokenSecret;

//remove all stored OAuth info from the keychain and reset state in memory
- (void)logout;

- (BOOL)handleOpenURL:(NSURL *)url;

@property(nonatomic, readonly, retain) NSArray *friends;  // Array of user identifiers of friends for the local user. Not valid until loadFriendsWithCompletionHandler: has completed.

// Asynchronously load the friends list as an array of user identifiers. Calls completionHandler when finished. Error will be nil on success.
// Possible reasons for error:
// 1. Communications problem
// 2. Unauthenticated player
- (void)loadFriendsWithCompletionHandler:(FindFriendsHandler)completionHandler;

// Load the users for the identifiers provided. The array contains FacebookUser objects. Error will be nil on success.
// Possible reasons for error:
// 1. Unauthenticated local user
// 2. Communications failure
// 3. Invalid user identifier
- (void)loadUsersForIdentifiers:(NSArray *)identifiers 
          withCompletionHandler:(LoadUsersHandler)completionHandler;

// Create a photo album for the user. The array contains photos to add to the album at time of creation. This can be nil. Error will be nil on success.
// Possible reasons for error:
// 1. Unauthenticated local user
// 2. Communications failure
// 3. Invalid user identifier
- (void)createPhotoAlbumWithName:(NSString*)name 
                         message:(NSString*)message 
                          photos:(NSArray*)photos 
           withCompletionHandler:(CreatePhotoAlbumHandler)completionHandler;

// Asynchronously load the photo albums of the user as an array of FacebookPhotoAlbum objects. Error will be nil on success.
// Possible reasons for error:
// 1. Unauthenticated local user
// 2. Communications failure
// 3. Invalid user identifier
- (void)loadPhotoAlbumsWithCompletionHandler:(LoadPhotoAlbumsHandler)completionHandler;

@end

// Notification will be posted whenever authentication status changes.
//extern NSString *UserAuthenticationDidChangeNotificationName;
