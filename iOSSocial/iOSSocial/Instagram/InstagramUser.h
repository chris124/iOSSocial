//
//  InstagramUser.h
//  InstaBeta
//
//  Created by Christopher White on 7/14/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "iOSSocialUser.h"
#import "iOSSocialConstants.h"

@class InstagramMediaCollection;

typedef void(^FetchMediaHandler)(InstagramMediaCollection *collection, NSError *error);

@class InstagramUserCollection;

typedef void(^FetchUsersHandler)(NSArray *users, NSError *error);

@interface InstagramUser : NSObject <iOSSocialUserProtocol>

//cwnote: should alias be copied?
@property(nonatomic, readonly, retain)  NSString *userID;               // User identifier.
@property(nonatomic, readonly, retain)  NSString *alias;                // The user's alias
@property(nonatomic, readonly, retain)  NSString *firstName;            // The user's first name
@property(nonatomic, readonly, retain)  NSString *lastName;             // The user's last name
@property(nonatomic, readonly, retain)  NSString *profilePictureURL;    // The user's last name
@property(nonatomic, readonly, retain)  NSString *bio;                  // The user's biography
@property(nonatomic, readonly, retain)  NSString *website;              // The user's website
@property(nonatomic, readonly, assign)  NSInteger mediaCount;           // The user's total number of media
@property(nonatomic, readonly, assign)  NSInteger followsCount;         // The user's number of people they follow
@property(nonatomic, readonly, assign)  NSInteger followedByCount;      // The user's total number of followers
//@property(nonatomic, readonly)          BOOL isFriend;          // True if this user is a friend of the local user

/**
 * The user source that the user belongs to.
 */
//@property (nonatomic, assign) id<iOSSUserSourceProtocol> userSource;

// Initialize a user with a dictionary object. The definition for the dictionary can be found here:
// http://instagram.com/developer/endpoints/users/
// Here is the example for those too lazy to go to the URL :D
/*
{
    "id": "1574083",
    "username": "snoopdogg",
    "first_name": "Snoop",
    "last_name": "Dogg",
    "profile_picture": "http://distillery.s3.amazonaws.com/profiles/profile_1574083_75sq_1295469061.jpg",
    "bio": "This is my bio",
    "website": "http://snoopdogg.com",
    "counts: {
    "media": 1320,
    "follows": 420,
    "followed_by": 3410 
    }
}
*/
- (id)initWithDictionary:(NSDictionary*)userDictionary;

// Asynchronously load the users's photo. Error will be nil on success.
// Possible reasons for error:
// 1. Communications failure
- (void)loadPhotoWithCompletionHandler:(LoadPhotoHandler)completionHandler;

- (void)fetchUserDataWithCompletionHandler:(FetchUserDataHandler)completionHandler;

- (void)fetchFollowedByWithCompletionHandler:(FetchUsersHandler)completionHandler;

//search for a user...q and count param
+ (void)searchUsersWithCompletionHandler:(FetchUsersHandler)completionHandler;

@end
